output "account_id" {
  value = local.account_id
}

output "efs_dns_name" {
  value = aws_efs_file_system.efs.dns_name
}

output "wp_lb_url" {
  value = aws_lb.web_alb.dns_name
}

output "wp_creds" {
  value = "${var.WP_USER} : ${random_string.wp_password.result}"
}

output "rds_address" {
  value = aws_db_instance.aws_s23-mysql.address
}

output "rds_creds" {
  value = "${var.DB_USER} : ${random_string.mysql_password.result}"
}

# Best option is generate access key throught IAM console or using keybase

# If we need console key access

# output "ec2_admin-key-creds" {
#   value = "${aws_iam_access_key.ec2_access.id} : ${aws_iam_access_key.ec2_access.encrypted_secret}"
# }

# output "db_admin-key-creds" {
#   value = "${aws_iam_access_key.db_access.id} : ${aws_iam_access_key.db_access.encrypted_secret}"
# }

output "ec2_admin-profile-creds" {
  value = "${aws_iam_user_login_profile.ec2_profile.id} : ${aws_iam_user_login_profile.ec2_profile.encrypted_password}"
}

output "db_admin-profile-creds" {
  value = "${aws_iam_user_login_profile.db_profile.id} : ${aws_iam_user_login_profile.db_profile.encrypted_password}"
}
