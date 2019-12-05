variable "aws_region" {
  default = "us-east-1"
}

# Where to download Vault
variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_linux_amd64.zip"
}
# CIDR of the VPC in which Vault is going to be placed.
variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "192.168.100.0/24"
}
# AZ
variable "aws_zone" {
  default = "us-east-1a"
}