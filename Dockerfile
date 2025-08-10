# syntax=docker/dockerfile:1.4

FROM registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9
USER root

RUN --mount=type=secret,id=hub_token \
    if [ -f /run/secrets/hub_token ]; then \
        echo "Secret file found"; \
        HUB_TOKEN=$(cat /run/secrets/hub_token); \
    else \
        echo "Secret file NOT found"; exit 1; \
    fi && \
    mkdir -p /etc/ansible && \
    printf "[galaxy]\nserver_list = automation_hub, galaxy\n\n\
[galaxy_server.automation_hub]\nurl=https://console.redhat.com/api/automation-hub/content/published/\ntoken=%s\n\n\
[galaxy_server.galaxy]\nurl=https://galaxy.ansible.com/\n" "$HUB_TOKEN" > /etc/ansible/ansible.cfg && \
    python3 -m pip install requests-oauthlib kubernetes jmespath PyYAML awxkit pymssql packaging gitpython pathlib && \
    ansible-galaxy collection install community.okd --disable-gpg-verify && \
    ansible-galaxy collection install community.general && \
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
    ansible-galaxy collection install ansible.controller --pre && \
    ansible-galaxy collection install awx.awx && \
    ansible-galaxy collection install theforeman.foreman && \
    ansible-galaxy collection install community.vmware && \
    ansible-galaxy collection install vmware.vmware && \
    python3 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt

ENV ANSIBLE_CONFIG=/etc/ansible/ansible.cfg
