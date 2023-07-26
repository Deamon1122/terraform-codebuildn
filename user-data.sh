#!/bin/bash

# update the repository
sudo apt-get update

# Download, Install and confg
sudo apt-get install git curl wget unzip software-properties-common -y

sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt-get install ansible -y

# restart SSM agent on Ubuntu
sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

#Clone a Repo :
git clone https://gitlab.com/kesav.kummari/ansible-role-tomcat.git

#go to repo
cd ansible-role-tomcat

# Execute the Playbook
ansible-playbook tomcat-setup.yml