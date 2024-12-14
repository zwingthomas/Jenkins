provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vault_network" {
  name                    = "vault-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vault_subnet" {
  name          = "vault-subnet"
  network       = google_compute_network.vault_network.id
  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_firewall" "allow_vault_tls" {
  name    = "allow-vault-tls"
  network = google_compute_network.vault_network.id

  allow {
    protocol = "tcp"
    ports    = ["8200"]
  }

  source_ranges = var.allowed_ip_ranges
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vault_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_ip_ranges
}

resource "google_compute_instance" "vault_server" {
  name         = "vault-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vault_subnet.id
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_file)}"
  }

  tags = ["vault"]
}

output "vault_server_ip" {
  value       = google_compute_instance.vault_server.network_interface.0.access_config.0.nat_ip
  description = "The external IP address of the Vault server"
}