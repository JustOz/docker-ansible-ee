FROM registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9
USER root

# Pass token at build time: docker build --build-arg HUB_TOKEN=xxxx
ARG HUB_TOKEN

# Create ansible.cfg for both Automation Hub and Galaxy
RUN mkdir -p /etc/ansible && \
    printf "[galaxy]\nserver_list = automation_hub, galaxy\n\n\
[galaxy_server.automation_hub]\nurl=https://console.redhat.com/api/automation-hub/content/published/\ntoken=%s\n\n\
[galaxy_server.galaxy]\nurl=https://galaxy.ansible.com/\n" "$HUB_TOKEN" > /etc/ansible/ansible.cfg

# Install python deps & collections
RUN python3 -m pip install requests-oauthlib \
    kubernetes jmespath PyYAML awxkit pymssql packaging pathlib gitpython && \
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
