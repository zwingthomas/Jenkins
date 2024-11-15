#!/bin/bash

# Prompt for installation choice and sudo password if needed
install_terraform() {
    read -p "Terraform is not installed. Would you like to install it? (y/n): " install_tf
    if [[ "$install_tf" == "y" || "$install_tf" == "Y" ]]; then
        read -s -p "Enter your sudo password: " SUDO_PASS
        echo ""
        echo "$SUDO_PASS" | sudo -S apt-get update
        echo "$SUDO_PASS" | sudo -S apt-get install -y gnupg software-properties-common curl
        echo "$SUDO_PASS" | sudo -S curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        echo "$SUDO_PASS" | sudo -S apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        echo "$SUDO_PASS" | sudo -S apt-get update && sudo apt-get install -y terraform
    else
        echo "Skipping Terraform installation."
    fi
}

install_ansible() {
    read -p "Ansible is not installed. Would you like to install it? (y/n): " install_ans
    if [[ "$install_ans" == "y" || "$install_ans" == "Y" ]]; then
        read -s -p "Enter your sudo password: " SUDO_PASS
        echo ""
        echo "$SUDO_PASS" | sudo -S apt-get update
        echo "$SUDO_PASS" | sudo -S apt-get install -y ansible
    else
        echo "Skipping Ansible installation."
    fi
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    install_terraform
else
    echo "Terraform is already installed."
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    install_ansible
else
    echo "Ansible is already installed."
fi

# Run terraform apply in the ./terraform directory
cd ./terraform || { echo "Terraform directory not found!"; exit 1; }

# Run terraform apply
echo "Running terraform apply..."
terraform apply -lock=false -auto-approve

# Extract the Jenkins server public IP using terraform output
JENKINS_IP=$(terraform output -raw jenkins_server_public_ip)

if [ -z "$JENKINS_IP" ]; then
    echo "Failed to retrieve Jenkins server public IP from Terraform outputs."
    exit 1
else
    echo "Jenkins server public IP: $JENKINS_IP"
fi

# Return to the base directory
cd ..

# Update the Ansible hosts.ini file with the Jenkins IP
HOSTS_FILE="./ansible/hosts.ini"

echo "Updating Ansible hosts.ini file with Jenkins server IP..."
cat > "$HOSTS_FILE" <<EOL
[jenkins]
$JENKINS_IP ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[local]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3
EOL

echo "Ansible hosts.ini file updated."

# Function to wait for SSH to become available
wait_for_ssh() {
    HOST=$1
    PORT=22
    echo "Waiting for SSH to become available on $HOST:$PORT..."
    until nc -z -v -w30 $HOST $PORT 2>/dev/null
    do
        echo "SSH is not yet available. Retrying in 10 seconds..."
        sleep 10
    done
    echo "SSH is now available on $HOST:$PORT"
}

# Wait for SSH to be available on the Jenkins server
wait_for_ssh "$JENKINS_IP"

# Run the ansible-playbook commands with the provided Vault password using process substitution
ANSIBLE_PLAYBOOK="ansible-playbook -i ./ansible/hosts.ini --private-key ~/.ssh/my-ec2-keypair -u ubuntu"

# Use process substitution to pass the Vault password without creating a file
$ANSIBLE_PLAYBOOK ./ansible/install_jenkins.yml --vault-password-file=vault_pass.txt
$ANSIBLE_PLAYBOOK ./ansible/plugins_jenkins.yml
$ANSIBLE_PLAYBOOK ./ansible/auth_jenkins.yml --vault-password-file=vault_pass.txt
$ANSIBLE_PLAYBOOK ./ansible/add_pipelines.yml --vault-password-file=vault_pass.txt

echo "All tasks completed."
