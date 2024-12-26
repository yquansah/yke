resource "aws_security_group" "yke_worker_node_sg" {
  name   = "yke-worker-node-sg"
  vpc_id = aws_vpc.yke_vpc.id
}

resource "aws_security_group_rule" "yke_worker_node_ingress_all_bgp" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_worker_node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 179
  to_port           = 179
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_worker_node_ingress_all_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_worker_node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_worker_node_ingress_vpc_kubelet" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_worker_node_sg.id
  cidr_blocks       = [var.vpc_cidr_range]
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_worker_node_ingress_vpc_kube_proxy" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_worker_node_sg.id
  cidr_blocks       = [var.vpc_cidr_range]
  from_port         = 10256
  to_port           = 10256
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_worker_node_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.yke_worker_node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = -1
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group" "yke_control_plane_sg" {
  name   = "yke-control-plane-sg"
  vpc_id = aws_vpc.yke_vpc.id
}

resource "aws_security_group_rule" "yke_control_plane_ingress_bgp_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_control_plane_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 179
  to_port           = 179
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_control_plane_ingress_all_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_control_plane_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_control_plane_ingress_elb_kube_api_server" {
  type                     = "ingress"
  security_group_id        = aws_security_group.yke_control_plane_sg.id
  source_security_group_id = aws_security_group.yke_elb_security_group.id
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "yke_control_plane_ingress_vpc_kube_api_server" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_control_plane_sg.id
  cidr_blocks       = [var.vpc_cidr_range]
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_control_plane_ingress_vpc_needed_ports" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_control_plane_sg.id
  cidr_blocks       = [var.vpc_cidr_range]
  from_port         = 10248
  to_port           = 10260
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_control_plane_ingress_vpc_etcd" {
  type              = "ingress"
  security_group_id = aws_security_group.yke_control_plane_sg.id
  cidr_blocks       = [var.vpc_cidr_range]
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
}

resource "aws_security_group_rule" "yke_control_plane_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.yke_control_plane_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = -1
  from_port         = 0
  to_port           = 0
}

resource "aws_key_pair" "yoofi_key" {
  key_name   = "yoofi_key_pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5CL5Rxf6h/xgGW1ad5I9n+fMuDpmkQJSpAtWCgjpOMrztbBYI4quIzU7pcfxBnMFwyl4aQ/yxLtA78LAXZ5TAlZiuQKvePtwjDzeEa6iU3Sqi84FGsQByNTW6N0j0JWtYsyzi8vwmEfUKNX7Lxoedaf2MaNJDIufGv28yysumde4xT6eUlNvU7Hiz0ZSsBuPw5co24awpidI/tefV+U4cSQLLGKL+z93tdp0o+gvaB0d2BD/V/n+N2WzY6jWk80WChjqtPzZHnDBGxYRMqp0dMpHqCvtmeBDz++/lkXo4k85TeMzAfWVASHdA60rHVzJaiJLzq/wEI/OCROMbJsOYBewBjkCdvDV2Qqie8lw99VmSR7WdbQMrBl4RSeBq2l2TCBSV7NlgmgsN9cOe8U9eBKKbvc8vIqa4jq2+y4Wid67VZ3B7sPcmpicJyvHBTfO6DAhpM/bgPtFzYxBAJBIHh/KfWSZU0lja98Zj6WaRxul5S5vuWVDiOt4dYZSZnUc= ybquansah@gmail.com"
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240809"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "yke_control_plane" {
  ami = data.aws_ami.ubuntu.id

  subnet_id = aws_subnet.yke_public_subnet[0].id

  instance_type = "t3.medium"

  key_name = aws_key_pair.yoofi_key.key_name

  vpc_security_group_ids = [aws_security_group.yke_control_plane_sg.id]

  user_data = file("scripts/init.yaml")

  tags = {
    Name      = "yke-control-plane-0"
    Component = "control-plane-node"
  }
}

resource "aws_instance" "yke_worker_node" {
  count = 2
  ami   = data.aws_ami.ubuntu.id

  subnet_id = aws_subnet.yke_public_subnet[0].id

  instance_type = "t3.medium"

  key_name = aws_key_pair.yoofi_key.key_name

  vpc_security_group_ids = [aws_security_group.yke_worker_node_sg.id]

  user_data = file("scripts/init.yaml")

  tags = {
    Name      = "yke-worker-${count.index}"
    Component = "worker-node"
  }
}
