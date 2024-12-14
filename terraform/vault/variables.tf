variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "zone" {
  description = "The GCP zone"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access Vault"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_ip_ranges" {
  description = "IP ranges allowed to SSH into the Vault server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "machine_type" {
  description = "The machine type for the Vault server"
  type        = string
  default     = "e2-medium"
}

variable "os_image" {
  description = "The OS image for the Vault server"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-11"
}

variable "ssh_public_key_file" {
  description = "The path to the SSH public key file for accessing the Vault server"
  type        = string
  default     = "~/.ssh/my_gce_keypair.pub"
}