# ---------- Stage 1: Build aha ----------
FROM fedora:40 AS aha_builder

RUN dnf install -y gcc make tar gzip curl \
 && curl -LO https://github.com/theZiz/aha/archive/refs/tags/v0.5.tar.gz \
 && tar xzf v0.5.tar.gz \
 && cd aha-0.5 && make

# ---------- Stage 2: Main image ----------
FROM registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9@sha256:fa3adff2c85d05a25c48ffc2adab87ecece0970aa2477346a8d5bf4b6196fe36

USER root

ARG HUB_TOKEN

# Configure Ansible with automation hub auth
RUN mkdir -p /etc/ansible && \
    printf "[galaxy]\nserver_list = automation_hub, galaxy\n\n\
[galaxy_server.automation_hub]\nurl=https://cloud.redhat.com/api/automation-hub/\nauth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token\ntoken=%s\n\n\
[galaxy_server.galaxy]\nurl=https://galaxy.ansible.com/\n" "$HUB_TOKEN" > /etc/ansible/ansible.cfg

# Copy python-requirements.txt and install Python modules
COPY python-requirements.txt /etc/python-requirements.txt

RUN microdnf install -y python3.11-pip python3.9-pip && \
    python3.11 -m pip install -r /etc/python-requirements.txt && \
    python3.9 -m pip install -r /etc/python-requirements.txt && \
    microdnf clean all

# Copy prebuilt aha binary from builder
COPY --from=aha_builder /aha-0.5/aha /usr/local/bin/aha

# Copy ansible-requirements.yml and install collections
COPY ansible-requirements.yml /etc/ansible-requirements.yml

RUN ansible-galaxy collection install -r /etc/ansible-requirements.yml --pre --disable-gpg-verify --force && \
    python3.11 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    python3.9 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    sed -i '/token=/d' /etc/ansible/ansible.cfg

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
