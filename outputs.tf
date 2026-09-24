output "vpc_id" {
  description = "ID da VPC criada pelo Terraform."
  value       = aws_vpc.lab.id
}

output "public_subnet_id" {
  description = "ID da subnet publica."
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "ID da instancia EC2."
  value       = aws_instance.lab.id
}

output "public_ip" {
  description = "Endereco IPv4 publico da instancia EC2."
  value       = aws_instance.lab.public_ip
}

output "ami_id" {
  description = "AMI Amazon Linux 2 utilizada na instancia."
  value       = aws_instance.lab.ami
}

output "ssh_command" {
  description = "Comando SSH para acessar a instancia."
  value       = "ssh -i ~/.ssh/terraform-lab ec2-user@${aws_instance.lab.public_ip}"
}