#!/bin/bash

set -euo pipefail

# Variables
CERT_DIR="/private/var/root/secure_certs"  # Secure directory for certs
SCRIPT_DIR="/private/var/root/scripts"    # Directory for this script
VAULT_CERT="${CERT_DIR}/vault.crt"
VAULT_KEY="${CERT_DIR}/vault.key"
VAULT_KEY_ENCRYPTED="${CERT_DIR}/vault.key.enc"
VAULT_CERT_ENCRYPTED="${CERT_DIR}/vault.crt.enc"
GCP_PROJECT="<YOUR_GCP_PROJECT>"
SECRET_MANAGER_CERT_NAME="vault-tls-cert"
SECRET_MANAGER_KEY_NAME="vault-tls-key"
TF_DIR="./terraform/vault"
ENCRYPTION_PASSWORD="my_secure_password"  # You can replace this with an environment variable or interactive prompt

# Ensure the secure directories exist with proper permissions
echo "Setting up secure directories..."
if [ ! -d "${CERT_DIR}" ]; then
  sudo mkdir -p "${CERT_DIR}"
  sudo chmod 700 "${CERT_DIR}"
fi

# Generate a private key and certificate
echo "Generating TLS certificate and private key..."
sudo openssl genrsa -out "${VAULT_KEY}" 4096
sudo openssl req -new -x509 -key "${VAULT_KEY}" -out "${VAULT_CERT}" -days 365 \
  -subj "/C=US/ST=State/L=City/O=YourOrg/OU=IT/CN=vault.local"

# Encrypt the private key and certificate
echo "Encrypting the private key and certificate..."
sudo openssl enc -aes-256-cbc -salt -in "${VAULT_KEY}" -out "${VAULT_KEY_ENCRYPTED}" -k "${ENCRYPTION_PASSWORD}"
sudo openssl enc -aes-256-cbc -salt -in "${VAULT_CERT}" -out "${VAULT_CERT_ENCRYPTED}" -k "${ENCRYPTION_PASSWORD}"

# Remove plaintext key and certificate
sudo rm -f "${VAULT_KEY}" "${VAULT_CERT}"

# Decrypt the key and certificate for GCP upload
echo "Decrypting the private key and certificate for GCP upload..."
VAULT_KEY=$(sudo openssl enc -aes-256-cbc -d -in "${VAULT_KEY_ENCRYPTED}" -k "${ENCRYPTION_PASSWORD}")
VAULT_CERT=$(sudo openssl enc -aes-256-cbc -d -in "${VAULT_CERT_ENCRYPTED}" -k "${ENCRYPTION_PASSWORD}")

# Upload the certificate and key to GCP Secret Manager
echo "Uploading TLS certificate and private key to GCP Secret Manager..."
gcloud secrets create "${SECRET_MANAGER_CERT_NAME}" --project="${GCP_PROJECT}" --replication-policy="automatic" || true
gcloud secrets versions add "${SECRET_MANAGER_CERT_NAME}" --data-file="${VAULT_CERT}"

gcloud secrets create "${SECRET_MANAGER_KEY_NAME}" --project="${GCP_PROJECT}" --replication-policy="automatic" || true
gcloud secrets versions add "${SECRET_MANAGER_KEY_NAME}" --data-file="${VAULT_KEY}"

# Remove plaintext key and certificate after upload
echo "Removing plaintext key and certificate..."
sudo rm -f "${VAULT_KEY}" "${VAULT_CERT}"

# Run Terraform to deploy Vault
echo "Running Terraform to deploy Vault..."
cd "${TF_DIR}"
terraform init
terraform apply -var="project_id=${GCP_PROJECT}" \
  -var="secret_cert_name=${SECRET_MANAGER_CERT_NAME}" \
  -var="secret_key_name=${SECRET_MANAGER_KEY_NAME}" -auto-approve

echo "Vault deployment complete!"