# NHTek Playbooks for Provisioning
Using [Ansible](https://docs.ansible.com/) for provisioning

Repo layout adapted from [Anisble Best Practices](https://docs.ansible.com/playbooks_best_practices.html#directory-layout)


# Tree
contrib/                  # Contains scripts / modules etc
   inventory              # AWS Dynamic Inventory script

nhc-plays/                # NH Clinical Playbooks
   playbook.yml           # A playbook

vagrant-plays/            # Vagrant Playbooks
   playbook.yml           # A playbook

aws-plays/                # AWS Playbooks
   playbook.yml           # A playbook

ansible.cfg               # NH ansible config
                          # Note: need to set roles_path

README.md                 # This file
