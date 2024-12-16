### How to run on Mac OS

1. sh standup.sh

2. Go out to the Jenkins server and run the pipeline with the desired configuration.

3. Check out the website.

4. Run the destroy Jenkines pipeline to destroy the resources you stood up.

5. sh teardown.sh

### Set up instructions

Using pyenv do the following to ensure you are on the right version of Ansible:
- pyenv virtualenv 3.11.6 ansible-11
- pyenv activate ansible-11
- pip install ansible==11.1.0 google-auth (and some jwemes thing) requests
- ansible --version
- pip install google-auth google-api-python-client google-cloud-secret-manager
- ansible-galaxy collection install google.cloud (requires version 1.4.1 or higher)

Create an auth_gcp.json file in the ansible folder. It should look something like the below:

{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "",
  "token_uri": "",
  "auth_provider_x509_cert_url": "",
  "client_x509_cert_url": "",
  "universe_domain": ""
}

Ensure it has the correct permissions to perform the actions it needs. Good luck. I did this months ago and don't want to back reference.
Then you need a credentials.yml file in your ansible folder as well. This should look like the following:

credentials:
  aws-credentials:
    access_key_id: "XXXXXXXXXXXXXXXXXXXX"
    secret_access_key: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  aws-account-id: "XXXXXXXXXXXX"
  aws-hosted-zone-id: "XXXXXXXXXXXXXXXXXXXXX"
  gcp-project: "XXXXXXXXX-XXXX-XXXXXX"
  gcp-credentials-file: "./auth_gcp.json"
  twilio-auth-token: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  azure-acr-credentials:
    username: "XXXXXXXXXXAppRegistry"
    password: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  azure-client-id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  azure-subscription-id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  azure-tenant-id: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  azure-client-secret: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
jenkins_username: "You will set these"
jenkins_password: "to whatever you want the Jenkins admin login to be"

You will also want to create a vault_pass.txt file in the main directory. In this you need to put the password you used to encrypt and decrypt the ansible credentials. The following commands are how you encrypt and decrypt it. Be sure to run the script with the credentials.yml file encrypted!

ansible-vault encrypt ansible/credentials.yml --vault-password-file vault_pass.txt
ansible-vault decrypt ansible/credentials.yml --vault-password-file vault_pass.txt
ansible-vault edit credentials.yml

Edit will decrypt the ansible credentials in memory to allow you to update the file.

Finally, you have to create a terraform.tfvars under ./terraform/vault:

project_id         = "XXXXXXXXX-XXXX-XXXXXX"
region             = "us-central1"
zone               = "us-central1-a"


### Also important
Register a domain and replace the APPLICATION_URL in your fork of the TEXT2SITE repository with your domain.
Ensure that the Jenkins pipeline set up in the Ansible hooks into your fork of the TEXT2SITE repository, not mine. This is on line 16 of add_pipelines.yml