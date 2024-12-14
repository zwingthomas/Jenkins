#!/bin/bash

set -e

# Function to delete Terraform resources
tear_down_terraform() {
    local dir="$1"
    echo "Tearing down Terraform resources in: $dir"
    
    if [ -d "$dir" ]; then
        cd "$dir"
        echo "Running terraform destroy in $dir..."
        terraform destroy -lock=false -auto-approve
        cd - >/dev/null
    else
        echo "Directory $dir not found. Skipping."
    fi
}

# Function to delete SSH key pairs
delete_ssh_keys() {
    local key_path="$1"

    # Define the private and public key paths
    local private_key="${key_path}"
    local public_key="${key_path}.pub"

    echo "Deleting SSH key pair: $key_path"

    # Check and delete private key
    if [ -f "$private_key" ]; then
        rm -f "$private_key"
        echo "Deleted: $private_key"
    else
        echo "Private key not found: $private_key"
    fi

    # Check and delete public key
    if [ -f "$public_key" ]; then
        rm -f "$public_key"
        echo "Deleted: $public_key"
    else
        echo "Public key not found: $public_key"
    fi
}

# Tear down Terraform resources for Jenkins and Vault
tear_down_terraform "./terraform/jenkins"
tear_down_terraform "./terraform/vault"

# Delete SSH key pairs
delete_ssh_keys "${HOME}/.ssh/my-ec2-keypair"
delete_ssh_keys "${HOME}/.ssh/my-gce-keypair"

echo "Terraform resources destroyed and SSH keys deleted."

# End of script