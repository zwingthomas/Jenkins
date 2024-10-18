output "ansible_inventory" {
  value = "[jenkins]\n${aws_instance.jenkins_server.public_ip}"
}


terraform {
  backend "s3" {
    bucket         = "terraform-state-354923279633"
    key            = "jenkins/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}