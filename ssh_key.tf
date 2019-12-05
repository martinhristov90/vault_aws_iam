# Creating SSH to connect to the Vault server
# Just a key
resource "tls_private_key" "vault-ssh-key" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.vault-ssh-key.private_key_pem}\" > private.key"
  }
  # Saving it to the local dir, so to be able to connect to Vault server in AWS
  provisioner "local-exec" {
    command = "chmod 600 private.key"
  }
}

# EC2 is dependent on this key
resource "aws_key_pair" "vault-ssh-key" {
  key_name   = "vault-ssh-key-${random_pet.env.id}"
  public_key = tls_private_key.vault-ssh-key.public_key_openssh
}