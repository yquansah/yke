resource "aws_vpc" "yke_vpc" {
  cidr_block       = var.vpc_cidr_range
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "yke_igw" {
  vpc_id = aws_vpc.yke_vpc.id
}

resource "aws_route_table" "yke_rt" {
  vpc_id = aws_vpc.yke_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yke_igw.id
  }
}

resource "aws_subnet" "yke_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.yke_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "yke_rt_public_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.yke_public_subnet[count.index].id
  route_table_id = aws_route_table.yke_rt.id
}

resource "aws_network_acl" "yke_nacl" {
  vpc_id = aws_vpc.yke_vpc.id
}

resource "aws_network_acl_rule" "yke_nacl_rule_ingress" {
  network_acl_id = aws_network_acl.yke_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "yke_nacl_rule_egress" {
  network_acl_id = aws_network_acl.yke_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "yke_nacl_association" {
  count          = length(var.public_subnet_cidrs)
  network_acl_id = aws_network_acl.yke_nacl.id
  subnet_id      = aws_subnet.yke_public_subnet[count.index].id
}
