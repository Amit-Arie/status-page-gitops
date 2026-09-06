output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "k3s_server_public_ip" {
  value = aws_eip.k3s_server.public_ip
}

output "k3s_agent_private_ip" {
  value = aws_instance.k3s_agent.private_ip
}

output "k3s_agent_instance_id" {
  value = aws_instance.k3s_agent.id
}

output "k3s_agent_ssm_connect_command" {
  value = "aws ssm start-session --target ${aws_instance.k3s_agent.id}"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ssh_command_k3s" {
  value = "ssh -i /path/to/${var.key_pair_name}.pem ubuntu@${aws_eip.k3s_server.public_ip}"
}
