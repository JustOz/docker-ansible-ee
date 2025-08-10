FROM registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9
USER root
RUN python3 -m pip install requests-oauthlib ; \
    python3 -m pip install kubernetes ; \
    python3 -m pip install jmespath ; \
    python3 -m pip install PyYAML ; \
    python3 -m pip install awxkit ; \
    python3 -m pip install pymssql ; \
    python3 -m pip install packaging ; \
    python3 -m pip install os ; \
    python3 -m pip install pathlib ; \
    python3 -m pip install gitpython ; \
    ansible-galaxy collection install community.okd --disable-gpg-verify ; \
    ansible-galaxy collection install community.general ; \
    ansible-galaxy collection install ansible.netcommon ; \
    ansible-galaxy collection install ansible.posix ; \
    ansible-galaxy collection install ansible.utils ; \
    ansible-galaxy collection install ansible.windows ; \
    ansible-galaxy collection install esp.bitbucket ; \
    ansible-galaxy collection install community.windows ; \
    ansible-galaxy collection install microsoft.ad ; \
    ansible-galaxy collection install microsoft.sql ; \
    ansible-galaxy collection install f5networks.f5_modules ; \
    ansible-galaxy collection install fortinet.fortios ; \
    ansible-galaxy collection install fortinet.fortimanager ; \
    ansible-galaxy collection install ansible.controller ; \
    ansible-galaxy collection install awx.awx ; \
    ansible-galaxy collection install theforeman.foreman ; \
    ansible-galaxy collection install community.vmware ; \
    ansible-galaxy collection install vmware.vmware ; \
    python3 -m pip install -r ~/.ansible/collections/ansible_collections/community/vmware/requirements.txt
