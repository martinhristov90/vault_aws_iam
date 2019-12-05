# Here EC2 in which Vault is going to be run is created 

# Getting the lates Ubuntu image
data "aws_ami" "ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Creating the EC2 that Vault is going to run in :

resource "aws_instance" "vault" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count         = 1
  subnet_id     = aws_subnet.public_subnet.id         # Subnet for the EC2 
  key_name      = aws_key_pair.vault-ssh-key.key_name # Waiting on the key to be created first

  security_groups = [
    aws_security_group.vault.id,
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  # The intance profile is going to give the EC2 (using meta-data) short-lived STS credentials to access the AWS IAM
  # Credentials are available locally for the EC2 at : http://169.254.169.254/latest/meta-data/iam....
  iam_instance_profile = aws_iam_instance_profile.vault-ec2-instance-profile.id

  tags = {
    Name = "vault-iam-aws-${random_pet.env.id}"
  }
  # Provisioning Vault
  user_data = data.template_file.vault.rendered
}

# Installing and provisioning Vault with this template file
data "template_file" "vault" {
  template = file("userdata.tpl")

  vars = {
    vault_url  = var.vault_url
    aws_region = var.aws_region
  }
}

