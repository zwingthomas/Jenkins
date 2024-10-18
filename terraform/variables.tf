variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  default     = "jenkins-server"
}

variable "key_pair_name" {
  description = "Name of the existing EC2 Key Pair to enable SSH access"
  type        = string
  default     = "my-ec2-keypair"  # Replace with your key pair name
}

variable "allowed_cidr" {
  description = "CIDR blocks allowed to access Jenkins (e.g., your IP)"
  default     = "0.0.0.0/0"  # Replace with your IP or CIDR block
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  default     = "t3.small"
}

variable "jenkins_admin_username" {
  description = "Admin username for Jenkins"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Admin password for Jenkins"
  type        = string
}
