FROM registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9@sha256:fa3adff2c85d05a25c48ffc2adab87ecece0970aa2477346a8d5bf4b6196fe36
USER root

ARG HUB_TOKEN

RUN mkdir -p /etc/ansible && \
    printf "[galaxy]\nserver_list = automation_hub, galaxy\n\n\
[galaxy_server.automation_hub]\nurl=https://cloud.redhat.com/api/automation-hub/\nauth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token\ntoken=%s\n\n\
[galaxy_server.galaxy]\nurl=https://galaxy.ansible.com/\n" "$HUB_TOKEN" > /etc/ansible/ansible.cfg && \
    python3 -m pip install requests-oauthlib kubernetes jmespath PyYAML awxkit pymssql packaging gitpython pathlib netaddr lxml psycopg2-binary jsonpatch  && \
    ansible-galaxy collection install --force ansible.controller --pre && \
    ansible-galaxy collection install --force redhat.rhbk --pre && \
    ansible-galaxy collection install --force redhat.satellite --pre && \
    ansible-galaxy collection install --force redhat.satellite_operations --pre && \
    ansible-galaxy collection install --force redhat.openshift --pre && \
    ansible-galaxy collection install --force community.general && \
    ansible-galaxy collection install --force community.okd --disable-gpg-verify && \
    ansible-galaxy collection install --force ansible.netcommon && \
    ansible-galaxy collection install --force ansible.posix && \
    ansible-galaxy collection install --force ansible.utils && \
    ansible-galaxy collection install --force ansible.windows && \
    ansible-galaxy collection install --force esp.bitbucket && \
    ansible-galaxy collection install --force community.windows && \
    ansible-galaxy collection install --force microsoft.ad && \
    ansible-galaxy collection install --force microsoft.sql && \
    ansible-galaxy collection install --force community.postgresql && \
    ansible-galaxy collection install --force f5networks.f5_modules && \
    ansible-galaxy collection install --force fortinet.fortios && \
    ansible-galaxy collection install --force fortinet.fortimanager && \
    ansible-galaxy collection install --force awx.awx && \
    ansible-galaxy collection install --force theforeman.foreman && \
    ansible-galaxy collection install --force community.vmware && \
    ansible-galaxy collection install --force vmware.vmware && \
    python3 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    sed -i '/token=/d' /etc/ansible/ansible.cfg

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
