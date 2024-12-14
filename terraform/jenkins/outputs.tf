output "jenkins_server_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_server_public_dns" {
  description = "Public DNS name of the Jenkins server"
  value       = aws_instance.jenkins_server.public_dns
}
