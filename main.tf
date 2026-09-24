# VPC principal do laboratorio
resource "aws_vpc" "lab" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-lab-vpc"
  }
}

# Subnet publica do laboratorio
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-lab-public-subnet"
  }
}

# Internet Gateway associado a VPC
resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "terraform-lab-igw"
  }
}

# Tabela de rotas da subnet publica
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "terraform-lab-public-rt"
  }
}

# Rota padrao para acesso a internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab.id
}

# Associa a subnet publica a tabela de rotas publica
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group da instancia EC2
resource "aws_security_group" "ssh" {
  name        = "terraform-lab-ssh-sg"
  description = "Permite acesso SSH somente a partir do IP autorizado"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name = "terraform-lab-ssh-sg"
  }
}

# Regra de entrada para SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ssh.id

  description = "SSH a partir do IP autorizado"
  cidr_ipv4   = var.ssh_cidr

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# Regra de saida para acesso a internet
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ssh.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Key Pair utilizada para acesso SSH a instancia
resource "aws_key_pair" "lab" {
  key_name   = var.key_pair_name
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = {
    Name = "terraform-lab-key"
  }
}

# Busca a imagem Amazon Linux 2 mais recente disponivel na regiao
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Instancia EC2 do laboratorio
resource "aws_instance" "lab" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ssh.id
  ]

  key_name = aws_key_pair.lab.key_name

  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "terraform-lab-ec2"
  }

}