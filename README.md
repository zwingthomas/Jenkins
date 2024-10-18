### You're in the right place! 

First, create an account and get a phone number from twilio. Save the auth code for later, you will specify it in your Jenkins global credentials.

All commands are to be run from the terraform directory.

Generate a key pair as .ssh/my-ec2-keypair and .ssh/my-ec2-keypair.pub

Run the terraform first

 - terraform plan
 - terraform apply

Then run the following command before running ansible

 - terraform output ansible_inventory > ../ansible/hosts.ini

Optionally remove stated EOF from host.ini

Finally run:
 - ansible-playbook -i ../ansible/hosts.ini ../ansible/install_jenkins.yml --private-key ~/.ssh/my-ec2-keypair -u ubuntu

Optionally run:
 - terraform destroy

Then to set up the Jenkins server to autodeploy the Text-Anything repository. You will need to create a new item: pipeline. When making this item specify the repository and select SCM webhook. Optionally, disable concurrent builds and abort previous builds. Finally, asfter specifying the Jenkinsfile which is located in the root of the repository, create the pipeline.

Install Pipeline Utility Steps plugin.

The pipeline will fail until you specify twilio-auth-token in the global credential fields. You can find these on the twilio console.

Verification step will always fail as there is not yet Route 53 DNS for this project.
