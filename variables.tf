variable "aws_region" {
  description = "Regiao AWS onde os recursos do laboratorio serao criados."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "Bloco CIDR da subnet publica."
  type        = string
}

variable "instance_type" {
  description = "Tipo da instancia EC2."
  type        = string
}

variable "ssh_cidr" {
  description = "Endereco IP autorizado a acessar a instancia via SSH."
  type        = string
}

variable "key_pair_name" {
  description = "Nome da Key Pair que sera criada na AWS."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Caminho local para a chave publica SSH."
  type        = string
}