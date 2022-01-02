resource "aws_iam_user" "ec2_admin" {
  name = "fedor"
}

resource "aws_iam_user" "db_admin" {
  name = "semen"
}

resource "aws_iam_group" "s23_group" {
  name = "s23_users"
}

resource "aws_iam_group_membership" "s23_team" {
  name = "s23-team"

  users = [
    aws_iam_user.ec2_admin.name,
    aws_iam_user.db_admin.name,
  ]

  group = aws_iam_group.s23_group.name
}

# Best option is generate access key throught IAM console or using keybase

# resource "aws_iam_access_key" "ec2_access" {
#   user = aws_iam_user.ec2_admin.name
#   # pgp_key = file("pgp/key.txt")
#   # used one key for testing purposes
#   pgp_key = "keybase:maxxv"
# }

resource "aws_iam_user_login_profile" "ec2_profile" {
  user = aws_iam_user.ec2_admin.name
  # Create your own keybase user!
  # used one key for testing purposes 
  pgp_key = "keybase:maxxv"
}

# resource "aws_iam_access_key" "db_access" {
#   user = aws_iam_user.db_admin.name
#   # pgp_key = "base-64 encoded PGP public key"
#   # used one key for testing purposes
#   pgp_key = "keybase:maxxv"
# }

resource "aws_iam_user_login_profile" "db_profile" {
  user = aws_iam_user.db_admin.name
  # Create your own keybase user!
  # used one key for testing purposes
  pgp_key = "keybase:maxxv"
}
#============================= EC2 =================================

resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : "ec2:*",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "elasticloadbalancing:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "cloudwatch:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "autoscaling:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : [
              "autoscaling.amazonaws.com",
              "ec2scheduled.amazonaws.com",
              "elasticloadbalancing.amazonaws.com",
              "spot.amazonaws.com",
              "spotfleet.amazonaws.com",
              "transitgateway.amazonaws.com"
            ]
          }
        }
      },
      #This is a mandatory part, user can't change password without it
      {
        "Effect" : "Allow",
        "Action" : "iam:GetAccountPasswordPolicy",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:ChangePassword",
        "Resource" : "arn:aws:iam::${local.account_id}:user/${aws_iam_user.ec2_admin.name}"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_rp-attach" {
  name       = "ec2_rp-attach"
  users      = [aws_iam_user.ec2_admin.name]
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

#============================= RDS =================================

resource "aws_iam_policy" "rds_policy" {
  name = "rds_policy"
  #role = aws_iam_role.rds_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "rds:*"
        ],
        "Effect" : "Allow",
        "Resource" : ["arn:aws:rds:${var.REGION}:${local.account_id}:db:*"]
      },
      {
        "Action" : "pi:*",
        "Effect" : "Allow",
        "Resource" : "arn:aws:pi:*:*:metrics/rds/*"
      },
      {
        "Action" : "iam:CreateServiceLinkedRole",
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : [
              "rds.amazonaws.com",
              "rds.application-autoscaling.amazonaws.com"
            ]
          }
        }
      },
      #This is a mandatory part, user can't change password without it
      {
        "Effect" : "Allow",
        "Action" : "iam:GetAccountPasswordPolicy",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:ChangePassword",
        "Resource" : "arn:aws:iam::${local.account_id}:user/${aws_iam_user.db_admin.name}"
      }
    ]
  })
}

resource "aws_iam_role" "rds_role" {
  name = "rds_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "rds_rp-attach" {
  name       = "rds_rp-attach"
  users      = [aws_iam_user.db_admin.name]
  roles      = [aws_iam_role.rds_role.name]
  policy_arn = aws_iam_policy.rds_policy.arn
}
