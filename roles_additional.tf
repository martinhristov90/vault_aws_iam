# This files creates roles and gives permission to the role used as `root` of Vault to assume our newly created role (create_ami role).
data "aws_iam_policy_document" "additional-inline-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::938620692197:role/${aws_iam_role.create_ami-role.id}", # ARN OF create_ami role here.
    ]
  }
}

resource "aws_iam_role_policy" "vault-iam-role-additional-policy" {
  name   = "Vault-iam-permission-to-assume-create_ami-role-${random_pet.env.id}"            # Just a name
  role   = aws_iam_role.vault-iam-root-role.id              # The id of the role
  policy = data.aws_iam_policy_document.additional-inline-policy.json # Actual policy that allows to use IAM
}

# Creating the `create_ami` role

# Actual policy and permissions that the create_ami is going to give to the end user.
# Example role that can manipulate AMIs, usually used for Packer
data "aws_iam_policy_document" "create_ami-permissions" {
  statement {
    sid       = "CreateAMI"
    effect    = "Allow"
    resources = ["*"]

    actions = [
        "ec2:CreateImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:ImportImage",
        "ec2:RegisterImage"
    ]
  }
}

# How can assume that role ? The create_ami role can be assume by the role used as `root` of Vault (aws_iam_role.vault-iam-root-role.id). 
data "aws_iam_policy_document" "create_ami-trusted-entities" {
  statement {
    effect    = "Allow"
    principals  {
        type = "AWS"
        identifiers = ["arn:aws:iam::938620692197:role/${aws_iam_role.vault-iam-root-role.id}"] # Arn of root vault role here
    }
    actions = ["sts:AssumeRole"]
  }
}

# Creatin the create_ami role
resource "aws_iam_role" "create_ami-role" {
  name               = "create_ami-role-${random_pet.env.id}"
  assume_role_policy = data.aws_iam_policy_document.create_ami-trusted-entities.json
}

resource "aws_iam_role_policy" "create_ami-role-policy" {
  name   = "create_ami-role-${random_pet.env.id}"            # Just a name
  role   = aws_iam_role.create_ami-role.id              # The id of the role
  policy = data.aws_iam_policy_document.create_ami-permissions.json # Actual policy that allows to use IAM
}
