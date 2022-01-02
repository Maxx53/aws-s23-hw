
#Do not use special characters as they broke wp-install.sh
resource "random_string" "wp_password" {
  length  = 10
  special = false
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_file" "wp-template" {
  template = file("wp-install.sh")

  vars = {
    EFS_NAME = "${aws_efs_file_system.efs.dns_name}"
    ELB_NAME = "${aws_lb.web_alb.dns_name}"
    DB_NAME  = var.DB_NAME

    # Not really need, AWSAuthenticationPlugin only supported with Aurora
    DB_IAM = "${aws_iam_user.db_admin.name}"

    DB_USER     = var.DB_USER
    DB_PASSWORD = random_string.mysql_password.result
    DB_HOST     = "${aws_db_instance.aws_s23-mysql.address}"
    WP_TITLE    = "Stream 23 AWS homework"
    WP_USER     = var.WP_USER
    WP_PASS     = random_string.wp_password.result
    WP_EMAIL    = "${var.WP_USER}@${aws_lb.web_alb.dns_name}"
  }
}

resource "aws_launch_configuration" "web_lc" {
  name            = "LC-WP"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.web-sg.id}"]
  user_data       = data.template_file.wp-template.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg" {

  name       = "Wordpress-ASG"
  depends_on = [aws_launch_configuration.web_lc]

  launch_configuration = aws_launch_configuration.web_lc.name
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  min_elb_capacity     = 2

  wait_for_capacity_timeout = "15m"

  health_check_type   = "ELB"
  vpc_zone_identifier = aws_subnet.aws_s23_subnet_az[*].id
  target_group_arns   = ["${aws_lb_target_group.web_tg.arn}"]

  dynamic "tag" {
    for_each = {
      Name = "Wordpress-ASG"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

