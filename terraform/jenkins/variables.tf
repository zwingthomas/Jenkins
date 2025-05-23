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
  default     = "my-ec2-keypair"
}

variable "allowed_cidr" {
  description = "CIDR blocks allowed to access Jenkins (e.g., your IP)"
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  default     = "t3.small"
}