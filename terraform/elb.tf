resource "aws_security_group" "kubeadm_alb_security_group" {
  name   = "application_lb"
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "kubeadm_alb_inbound_https" {
  security_group_id = aws_security_group.kubeadm_alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "kubeadm_alb_inbound_http" {
  security_group_id = aws_security_group.kubeadm_alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "kubeadm_alb_inbound_kube_https" {
  security_group_id = aws_security_group.kubeadm_alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
}

resource "aws_vpc_security_group_egress_rule" "kubeadm_alb_outbound" {
  security_group_id = aws_security_group.kubeadm_alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_lb" "kubeadm_elb" {
  name               = "kubeadm-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kubeadm_alb_security_group.id]
  subnets            = [for subnet in aws_subnet.kubeadm_public_subnet : subnet.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "kubeadm_target_group" {
  name        = "kubeadm-target-group"
  port        = 6443
  protocol    = "HTTP"
  vpc_id      = aws_vpc.kubeadm_vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "kubeadm_target_group_attachment" {
  target_group_arn = aws_lb_target_group.kubeadm_target_group.arn
  for_each = {
    for k, v in aws_instance.kubeadm_instance :
    k => v
  }

  target_id = each.value.id
}


resource "aws_lb_listener" "kubeadm_listener" {
  load_balancer_arn = aws_lb.kubeadm_elb.arn
  port              = "6443"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubeadm_target_group.arn
  }
}
