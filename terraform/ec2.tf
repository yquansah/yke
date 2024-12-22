resource "aws_security_group" "kubeadm_security_group" {
  name   = "kubeadm-security-group"
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_security_group_rule" "kubeadm_ingress_ssh_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.kubeadm_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "kubeadm_ingress_ports_all_rule" {
  type                     = "ingress"
  security_group_id        = aws_security_group.kubeadm_security_group.id
  source_security_group_id = aws_security_group.kubeadm_elb_security_group.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "kubeadm_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.kubeadm_security_group.id
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

resource "aws_instance" "kubeadm_control_plane" {
  ami = data.aws_ami.ubuntu.id

  subnet_id = aws_subnet.kubeadm_public_subnet[0].id

  instance_type = "t3.medium"

  key_name = aws_key_pair.yoofi_key.key_name

  vpc_security_group_ids = [aws_security_group.kubeadm_security_group.id]

  user_data = file("scripts/init.yaml")

  tags = {
    Name      = "kubeadm-control-plane-0"
    Component = "control-plane-node"
  }
}

resource "aws_instance" "kubeadm_worker" {
  count = 2
  ami   = data.aws_ami.ubuntu.id

  subnet_id = aws_subnet.kubeadm_public_subnet[0].id

  instance_type = "t3.medium"

  key_name = aws_key_pair.yoofi_key.key_name

  vpc_security_group_ids = [aws_security_group.kubeadm_security_group.id]

  user_data = file("scripts/init.yaml")

  tags = {
    Name      = "kubeadm-worker-${count.index}"
    Component = "worker-node"
  }
}
