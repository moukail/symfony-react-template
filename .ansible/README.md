# Install Python3 on local
sudo apt install python3 python3-pip python3-pymysql
# Install Ansible Collections on host
ansible-galaxy collection install amazon.aws
ansible-galaxy install DavidWittman.redis



ansible aws-staging --list-hosts -i ansible/hosts.ini
#ansible-playbook ansible/playbook.yml -i ansible/hosts.ini --ask-vault-pass
ansible-playbook ansible/playbook.yml -i ansible/hosts.ini


sudo firewall-cmd --zone=public --permanent --add-port=8000/tcp
sudo firewall-cmd --reload



# How to Create an Encrypted File in Ansible
ansible-vault create ansible/vars/vault.yml
# How to View an Encrypted File in Ansible
ansible-vault view ansible/vars/vault.yml
# How to Edit an Encrypted File in Ansible
ansible-vault edit ansible/vars/vault.yml
#How to Change Ansible Vault Password
ansible-vault rekey ansible/vars/vault.yml
# How to Encrypt an Unencrypted File in Ansible
ansible-vault encrypt classified.txt
ansible-vault decrypt classified.txt

ansible-vault encrypt_string --vault-id @prompt secret_text
ansible-vault encrypt_string mypass --name login_password
ansible-playbook ansible/aws_services.yml --vault-id @prompt
ansible-playbook ansible/webserver.yml -i ansible/hosts.ini


ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook .ansible/main.yml -i .ansible/hosts.ini
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook .ansible/db.yml -i .ansible/hosts.ini

ssh -i ~/id_ed25519 ubuntu@ch2.moukafih.nl "mysql --user root --password=$PASSWORD demo" < ./.docker/data/database2022-11-02_09_40_22.sql
