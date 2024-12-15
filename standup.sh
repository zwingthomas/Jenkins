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

generate_keypair() {
  local key_path="$1" # The path to the key file without an extension (e.g., "/home/user/.ssh/my_gce_keypair")

  # Validate arguments
  if [[ -z "$key_path" ]]; then
    echo "Usage: generate_keypair <key_path>"
    exit 1
  fi

  # Define the private and public key paths
  local private_key="${key_path}"
  local public_key="${key_path}.pub"

  echo "Debug: private_key=${private_key}"
  echo "Debug: public_key=${public_key}"

  # Overwrite existing keys if they exist
  if [[ -f "$private_key" || -f "$public_key" ]]; then
    echo "Existing key pair detected at $key_path. Overwriting..."
    rm -f "$private_key" "$public_key"
  fi

  # Generate the SSH key pair
  echo "Generating new SSH key pair at: $key_path"
  ssh-keygen -t rsa -b 4096 -C ubuntu -f "$private_key" -N ""

  # Verify key generation
  if [[ ! -f "$private_key" || ! -f "$public_key" ]]; then
    echo "Error: Key pair generation failed."
    exit 1
  fi

  # Set appropriate permissions
  chmod 600 "$private_key"
  chmod 644 "$public_key"

  echo "Key pair generated successfully: $private_key and $public_key"
}

# Generate keypairs for ansible access
if [[ ! -f "${HOME}/.ssh/my-ec2-keypair" ]]; then
    generate_keypair "${HOME}/.ssh/my-ec2-keypair"
fi
if [[ ! -f "${HOME}/.ssh/my-gce-keypair" ]]; then
    generate_keypair "${HOME}/.ssh/my-gce-keypair"
fi

# Function to run `terraform init` only if necessary
terraform_init_if_needed() {
    local terraform_dir="$1"

    echo "Checking if terraform init is needed in: $terraform_dir"
    if [ ! -d "$terraform_dir/.terraform" ]; then
        echo "Terraform init required. Running terraform init..."
        terraform init
    else
        echo "Terraform init not needed. Skipping."
    fi
}


# Run terraform apply in the ./terraform/jenkins directory
cd ./terraform/jenkins || { echo "Jenkins terraform directory not found!"; exit 1; }

# Run terraform apply
echo "Running terraform apply..."
# Run terraform init if necessary
terraform_init_if_needed "$(pwd)"
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
cd ../..

cd ./terraform/vault || { echo "Vault terraform directory not found!"; exit 1; }

# Run terraform apply
echo "Running terraform apply..."
# Run terraform init if necessary
terraform_init_if_needed "$(pwd)"
terraform apply -var="ssh_public_key_file=/Users/thomaszwinger/.ssh/my-gce-keypair.pub" -auto-approve -lock=false

# Extract the Jenkins server public IP using terraform output
VAULT_IP=$(terraform output -raw vault_server_public_ip)

if [ -z "$VAULT_IP" ]; then
    echo "Failed to retrieve Vault server public IP from Terraform outputs."
    exit 1
else
    echo "Jenkins server public IP: $VAULT_IP"
fi

# Return to the base directory
cd ../..

# Update the Ansible hosts.ini file with the Jenkins IP
HOSTS_FILE="./ansible/hosts.ini"

echo "Updating Ansible hosts.ini file with Jenkins and Vault server IP..."
cat > "$HOSTS_FILE" <<EOL
[vault]
$VAULT_IP ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_ssh_private_key_file=~/.ssh/my-gce-keypair ansible_python_interpreter=/usr/bin/python3.8

[jenkins]
$JENKINS_IP ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_ssh_private_key_file=~/.ssh/my-ec2-keypair

[local]
localhost ansible_connection=local
EOL

echo "Ansible hosts.ini file updated."
cat "$HOSTS_FILE"

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

# Wait for SSH to be available on the Jenkins and Vault servers
wait_for_ssh "$JENKINS_IP"
echo "Jenkins host can be accessed via SSH"
wait_for_ssh "$VAULT_IP"
echo "Vault host can be accessed via SSH"

# Run the ansible-playbook commands with the provided Vault password using process substitution
ANSIBLE_PLAYBOOK="ansible-playbook -i ./ansible/hosts.ini -u ubuntu"

# Use process substitution to pass the Vault password without creating a file
$ANSIBLE_PLAYBOOK ./ansible/vault.yml
$ANSIBLE_PLAYBOOK ./ansible/install_jenkins.yml --vault-password-file=vault_pass.txt
$ANSIBLE_PLAYBOOK ./ansible/plugins_jenkins.yml
$ANSIBLE_PLAYBOOK ./ansible/auth_jenkins.yml --vault-password-file=vault_pass.txt
$ANSIBLE_PLAYBOOK ./ansible/add_pipelines.yml --vault-password-file=vault_pass.txt

echo "All tasks completed."
