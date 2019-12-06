output "connections" {
  value = <<EOF
Connect to Vault via SSH : ssh ubuntu@${aws_instance.vault[0].public_ip} -i private.key
Vault web interface  http://${aws_instance.vault[0].public_ip}:8200/ui
EOF
}

output "create_ami-ARN" {
  value = "The ARN of create_ami role is : ${aws_iam_role.create_ami-role.arn}"
}
