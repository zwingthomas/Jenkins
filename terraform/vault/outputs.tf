output "vault_server_public_ip" {
  value       = google_compute_instance.vault_server.network_interface.0.access_config.0.nat_ip
  description = "The external IP address of the Vault server"
}