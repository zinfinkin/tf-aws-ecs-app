## ALB - Front-end public load balancer.
resource "aws_alb" "application_load_balancer" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = "${var.name}-alb"
  }
}

# HTTPS listener. 
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.alb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}

# HTTP listener. Redirects automatically to 443.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Security group attached to LB. Allows ingress from any IP but only on ports 443 and 80.
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "${var.name}-sg"
  }
}

# Target group to which LB listener are pointing. 
resource "aws_lb_target_group" "target_group" {
  name        = "${var.name}-tg"
  port        = 443
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.name}-lb-tg"
  }
}

# TLS cert - The below blocks generate a self-signed cert and upload to AWS Cert Mgmt - cert is then attached to HTTPS listener. 
# Will not show as secure because it is self-signed, but a cert is necessary to add HTTPS - using this just for demonstration. 
resource "tls_private_key" "alb_tls" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "alb_tls" {
  #key_algorithm   = "RSA"
  private_key_pem = tls_private_key.alb_tls.private_key_pem

  subject {
    common_name  = "*.elb.amazonaws.com"
    organization = "athome"
  }

  validity_period_hours = 730

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "alb_cert" {
  private_key      = tls_private_key.alb_tls.private_key_pem
  certificate_body = tls_self_signed_cert.alb_tls.cert_pem
}