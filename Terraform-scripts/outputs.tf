output "jump_server_public_ip" {
  description = "Public IP of the Jump Server"
  value       = aws_instance.jump_server.public_ip
}

output "jenkins_server_private_ip" {
  description = "Private IP of the Jenkins Server"
  value       = aws_instance.jenkins_server.private_ip
} 

# Output the private key (be careful with this in production)
output "private_key" {
  value     = tls_private_key.key_pair.private_key_pem
  sensitive = true
}