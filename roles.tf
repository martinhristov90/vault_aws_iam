# This file creates a role and attaches policies to it, so this role can be assumed by the EC2 in which Vault is running. The role is going to be used to create IAM users by Vault.
# Policy that allows EC2 service to assume the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# When the role is assumed, Vault is using it to create IAM users and STS credentials.
data "aws_iam_policy_document" "vault-root-iam-policy" {
  statement {
    sid       = "VaultRootPermissions"
    effect    = "Allow"
    resources = ["*"]

    actions = [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup"
    ]
  }
}
# Creating the actual role and assume_role_policy to the one created above, it is going to show in the `Trusted entities` tab

resource "aws_iam_role" "vault-iam-root-role" {
  name               = "vault-iam-role-${random_pet.env.id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attaching the policy to the role, this policy is `inline` to the role, not going to show in policies tab
resource "aws_iam_role_policy" "vault-iam-role-policy" {
  name   = "Vault-KMS-Unseal-${random_pet.env.id}"            # Just a name
  role   = aws_iam_role.vault-iam-root-role.id              # The id of the role
  policy = data.aws_iam_policy_document.vault-root-iam-policy.json # Actual policy that allows to use IAM
}

# This instance profile is used at launch of EC2, so it can assume the created role, and use it to access the KMS, in order to encrypt and decrypt the Vault seal master key
resource "aws_iam_instance_profile" "vault-ec2-instance-profile" {
  name = "vault-iam-instace-profile-${random_pet.env.id}"
  role = aws_iam_role.vault-iam-root-role.name
}

# end