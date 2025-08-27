FROM registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9@sha256:fa3adff2c85d05a25c48ffc2adab87ecece0970aa2477346a8d5bf4b6196fe36
USER root

ARG HUB_TOKEN

# Configure Ansible with automation hub auth
RUN mkdir -p /etc/ansible && \
    printf "[galaxy]\nserver_list = automation_hub, galaxy\n\n\
[galaxy_server.automation_hub]\nurl=https://cloud.redhat.com/api/automation-hub/\nauth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token\ntoken=%s\n\n\
[galaxy_server.galaxy]\nurl=https://galaxy.ansible.com/\n" "$HUB_TOKEN" > /etc/ansible/ansible.cfg

# Pre-install python dependencies used by some collections
RUN python3 -m pip install \
        requests-oauthlib \
        kubernetes \
        jmespath \
        PyYAML \
        awxkit \
        pymssql \
        packaging \
        gitpython \
        pathlib \
        netaddr \
        lxml \
        psycopg2-binary \
        jsonpatch

# Copy requirements.yml and install collections
COPY requirements.yml /etc/ansible-requirements.yml
RUN ansible-galaxy collection install -r /etc/ansible-requirements.yml --pre --disable-gpg-verify && \
    python3 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    sed -i '/token=/d' /etc/ansible/ansible.cfg

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
