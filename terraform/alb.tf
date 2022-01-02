resource "aws_lb" "web_alb" {
  name               = "wp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.elb-sg.id}"]
  subnets            = aws_subnet.aws_s23_subnet_az[*].id

  tags = {
    Name = "Wordpress-ALB"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_s23_vpc.id

  health_check {
    healthy_threshold   = 2
    interval            = 120
    timeout             = 30
    protocol            = "HTTP"
    unhealthy_threshold = 6
    matcher             = "200,301,302"
    path                = "/health"
  }

  depends_on = [
    aws_lb.web_alb
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Wordpress-TG"
  }
}

resource "aws_lb_listener" "web_ls" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = aws_autoscaling_group.web_asg.id
  alb_target_group_arn   = aws_lb_target_group.web_tg.arn
}
