FROM registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9
USER root

ARG HUB_TOKEN

RUN mkdir -p /etc/ansible && \
    printf "[galaxy]\nserver_list = automation_hub, galaxy\n\n\
[galaxy_server.automation_hub]\nurl=https://cloud.redhat.com/api/automation-hub/\nauth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token\ntoken=%s\n\n\
[galaxy_server.galaxy]\nurl=https://galaxy.ansible.com/\n" "$HUB_TOKEN" > /etc/ansible/ansible.cfg && \
    python3 -m pip install requests-oauthlib kubernetes jmespath PyYAML awxkit pymssql packaging gitpython pathlib && \
   # ansible-galaxy collection install ansible.controller --pre && \
    ansible-galaxy collection install community.general && \
    ansible-galaxy collection install community.okd --disable-gpg-verify && \
    ansible-galaxy collection install ansible.netcommon && \
    ansible-galaxy collection install ansible.posix && \
    ansible-galaxy collection install ansible.utils && \
    ansible-galaxy collection install ansible.windows && \
    ansible-galaxy collection install esp.bitbucket && \
    ansible-galaxy collection install community.windows && \
    ansible-galaxy collection install microsoft.ad && \
    ansible-galaxy collection install microsoft.sql && \
    ansible-galaxy collection install f5networks.f5_modules && \
    ansible-galaxy collection install fortinet.fortios && \
    ansible-galaxy collection install fortinet.fortimanager && \
    ansible-galaxy collection install awx.awx && \
    ansible-galaxy collection install theforeman.foreman && \
    ansible-galaxy collection install community.vmware && \
    ansible-galaxy collection install vmware.vmware && \
    python3 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt && \
    sed -i '/token=/d' /etc/ansible/ansible.cfg

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
