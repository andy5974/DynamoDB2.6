data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon2023.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]

  tags = {
    Name = "wx-ec2"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
 source  = "terraform-aws-modules/vpc/aws"


 name = "wx-vpc2"
 cidr = "10.0.0.0/16"


 azs             = data.aws_availability_zones.available.names #["ap-southeast-1a", "ap-southeast0-1b", "ap-southeast-1c"]
 private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
 public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


 enable_nat_gateway   = false
 single_nat_gateway   = true
 enable_dns_hostnames = true


 tags = {
  Terraform = "true"
 }
}

output "nat_gateway_ids" {
 value = module.vpc.natgw_ids
}


resource "aws_security_group" "sg" {
  name_prefix = "wx-security-group"
  description = "Allow SSH inbound and all outbound"
  vpc_id      = data.aws_vpc.selected.id #VPC Id of the default VPC
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_dynamodb_table" "wx-bookinventory" {
  name             = "wx-bookinventory"
  hash_key         = "ISBN"
  range_key        = "Genre"
  billing_mode   = "PAY_PER_REQUEST"
 
  
  attribute { 
    name = "ISBN" 
    type = "S" 
  } 

  attribute { 
    name = "Genre" 
    type = "S" 
  }
}