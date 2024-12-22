resource "aws_security_group" "kubeadm_elb_security_group" {
  name   = "network-lb-security-group"
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "kubeadm_elb_ingress_kube_https" {
  security_group_id = aws_security_group.kubeadm_elb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
}

resource "aws_vpc_security_group_egress_rule" "kubeadm_elb_egress" {
  security_group_id = aws_security_group.kubeadm_elb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_lb" "kubeadm_elb" {
  name               = "kubeadm-load-balancer"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.kubeadm_elb_security_group.id]
  subnets            = [for subnet in aws_subnet.kubeadm_public_subnet : subnet.id]

  tags = {
    Component = "load-balancer"
  }
}

resource "aws_lb_target_group" "kubeadm_target_group" {
  name        = "kubeadm-target-group"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.kubeadm_vpc.id
  target_type = "instance"

  health_check {
    enabled  = true
    interval = 30
    protocol = "TCP"
    port     = "6443"
  }
}

resource "aws_lb_target_group_attachment" "kubeadm_target_group_attachment" {
  target_group_arn = aws_lb_target_group.kubeadm_target_group.arn
  target_id        = aws_instance.kubeadm_control_plane.id
}


resource "aws_lb_listener" "kubeadm_listener" {
  load_balancer_arn = aws_lb.kubeadm_elb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubeadm_target_group.arn
  }
}
