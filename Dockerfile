# syntax=docker/dockerfile:1

# ---------- Main image ----------
FROM registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9@sha256:fa3adff2c85d05a25c48ffc2adab87ecece0970aa2477346a8d5bf4b6196fe36

USER root

ARG AUTOMATION_HUB_TOKEN

# Configure Ansible with automation hub auth
RUN mkdir -p /etc/ansible && cat > /etc/ansible/ansible.cfg <<EOF
[galaxy]
server_list = redhat_automation_hub, galaxy

[galaxy_server.redhat_automation_hub]
url=https://cloud.redhat.com/api/automation-hub/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token=${AUTOMATION_HUB_TOKEN}

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
    uv pip install --python python3.9 --system -r /etc/python-requirements.txt

# Copy ansible-requirements.yml and install collections
COPY ansible-requirements.yml /etc/ansible-requirements.yml

RUN --mount=type=cache,target=/root/.cache/uv \
    ansible-galaxy collection install -r /etc/ansible-requirements.yml --pre --disable-gpg-verify --force && \
    uv pip install --python python3.11 --system -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    uv pip install --python python3.9 --system -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    sed -i '/token=/d' /etc/ansible/ansible.cfg

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
