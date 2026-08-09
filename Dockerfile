# syntax=docker/dockerfile:1

# ---------- Main image ----------
FROM registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9@sha256:fa3adff2c85d05a25c48ffc2adab87ecece0970aa2477346a8d5bf4b6196fe36

USER root

# Configure Ansible with automation hub auth.
# The token itself is injected later via a secret mount (never an ARG/ENV),
# so it never lands in an image layer or `docker history`.
RUN mkdir -p /etc/ansible && cat > /etc/ansible/ansible.cfg <<EOF
[galaxy]
server_list = redhat_automation_hub, galaxy

[galaxy_server.redhat_automation_hub]
url=https://cloud.redhat.com/api/automation-hub/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token

[galaxy_server.galaxy]
url=https://galaxy.ansible.com/
EOF

# Install uv (copy the static binary from the official image; pin as desired)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy uv into a system location and avoid hardlink warnings on cache mounts
ENV UV_LINK_MODE=copy

# Copy python-requirements.txt and install Python modules
COPY python-requirements.txt /etc/python-requirements.txt

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --python python3.11 --system -r /etc/python-requirements.txt && \
    uv pip install --python python3.9 --system -r /etc/python-requirements.txt && \
    find /usr/lib/python3.11 /usr/lib64/python3.11 /usr/local/lib/python3.11 \
         /usr/lib/python3.9  /usr/lib64/python3.9  /usr/local/lib/python3.9 \
         -type d -name '__pycache__' -prune -exec rm -rf {} + 2>/dev/null || true

# Copy ansible-requirements.yml and install collections
COPY ansible-requirements.yml /etc/ansible-requirements.yml

# Token is mounted as a build secret (id must match --secret in the build command)
# and only ever exists on disk inside this single layer's temporary filesystem.
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=secret,id=automation_hub_token \
    sed -i "/\[galaxy_server.redhat_automation_hub\]/a token=$(cat /run/secrets/automation_hub_token)" /etc/ansible/ansible.cfg && \
    ansible-galaxy collection install -r /etc/ansible-requirements.yml --pre --disable-gpg-verify --force && \
    uv pip install --python python3.11 --system -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    uv pip install --python python3.9 --system -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    sed -i '/token=/d' /etc/ansible/ansible.cfg && \
    find ~/.ansible/collections/ansible_collections -mindepth 2 -maxdepth 4 -type d \
         \( -name tests -o -name test -o -name '.github' -o -name docs -o -name changelogs \) \
         -exec rm -rf {} + 2>/dev/null ; \
    find ~/.ansible/collections/ansible_collections -name '*.pyc' -delete && \
    rm -rf ~/.ansible/tmp

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
