# Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Providers
provider "aws" {
  region  = "us-east-1"
  profile = "Ayaz"
}

terraform {
  backend "s3" {
    bucket = "codebuildpipes3"
    key = "dev/terraform.state"
    region = "us-east-1"
    profile = "Ayaz"
  }
}

# Create a VPC in AWS part of region i.e. Mumbai 
resource "aws_vpc" "NewVpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name       = "NewVpc"
    Created_By = "iac - Terraform"
  }
}

# Create a Public-Subnet1 part of NewVpc 
resource "aws_subnet" "new_public_subnet1" {
  vpc_id                  = aws_vpc.NewVpc.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name       = "new_public_subnet1"
    created_by = "Terraform"
  }
}
resource "aws_subnet" "new_public_subnet2" {
  vpc_id                  = aws_vpc.NewVpc.id
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name       = "new_public_subnet2"
    created_by = "Terraform"
  }
}

resource "aws_subnet" "new_private_subnet1" {
  vpc_id            = aws_vpc.NewVpc.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name       = "new_private_subnet1"
    created_by = "Terraform"
  }
}
resource "aws_subnet" "new_private_subnet2" {
  vpc_id            = aws_vpc.NewVpc.id
  cidr_block        = "192.168.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name       = "new_private_subnet2"
    created_by = "Terraform"
  }
}

# RouteTable(RTB)
resource "aws_route_table" "new_rtb_public" {
  vpc_id = aws_vpc.NewVpc.id

  tags = {
    Name       = "new_rtb_public"
    Created_By = "Terraform"
  }
}
resource "aws_route_table" "new_rtb_private" {
  vpc_id = aws_vpc.NewVpc.id

  tags = {
    Name       = "new_rtb_private"
    Created_By = "Terraform"
  }
}

# Internet Gateway (IGW)
resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.NewVpc.id

  tags = {
    Name       = "new_igw"
    Created_By = "Terraform"
  }
}

# Create Routing to Public_RTB From IGW 
resource "aws_route" "new_rtb_igw" {
  route_table_id         = aws_route_table.new_rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.new_igw.id

}

# Subnet Association With Public Route Table (Adding Public Subnet to Public Route Table)
resource "aws_route_table_association" "new_subnet_association1" {
  subnet_id      = aws_subnet.new_public_subnet1.id
  route_table_id = aws_route_table.new_rtb_public.id
}
resource "aws_route_table_association" "new_subnet_association2" {
  subnet_id      = aws_subnet.new_public_subnet2.id
  route_table_id = aws_route_table.new_rtb_public.id
}

# Subnet Association With Private Route Table (Adding Private Subnet to Private Route Table)
resource "aws_route_table_association" "new_subnet_association3" {
  subnet_id      = aws_subnet.new_private_subnet1.id
  route_table_id = aws_route_table.new_rtb_private.id
}
resource "aws_route_table_association" "new_subnet_association4" {
  subnet_id      = aws_subnet.new_private_subnet2.id
  route_table_id = aws_route_table.new_rtb_private.id
}

# Elastic Ipaddress for NAT Gateway
resource "aws_eip" "elastic" {
  vpc = true
}

# NAT Gateway & attach EIP to NAT GATEWAY
resource "aws_nat_gateway" "new_natgw" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.new_public_subnet1.id

  tags = {
    Name      = "new_natgw"
    Createdby = "iac - Terraform"
  }
}


# Allow internet access from NAT Gateway to Private Route Table
resource "aws_route" "new_rtb_private_natgw" {
  route_table_id         = aws_route_table.new_rtb_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.new_natgw.id
}

# Network Access Control List 
resource "aws_network_acl" "new_nacl" {
  vpc_id = aws_vpc.NewVpc.id
  subnet_ids = [
    "${aws_subnet.new_public_subnet1.id}",
    "${aws_subnet.new_public_subnet2.id}",
    "${aws_subnet.new_private_subnet1.id}",
    "${aws_subnet.new_private_subnet2.id}"
    # aws_subnet.new_public_subnet1.id, aws_subnet.new_public_subnet2.id, aws_subnet.new_private_subnet1.id, aws_subnet.new_private_subnet2.id]
  ]

  # Allow ingress / inbound 
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  # Allow egress / outbound
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }


  tags = {
    Name      = "new_nacl"
    createdby = "iac - Terraform"
  }
}

# SG (Security group) For Bastion
resource "aws_security_group" "new_sg_bastion" {
  vpc_id      = aws_vpc.NewVpc.id
  name        = "sg_new_sshh"
  description = "Allow SSH and RDP"

  # Allow Ingress / inbound Of port 22 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 3389
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "new_sg_bastion"
    Description = "Allow SSH and RDP"
    createdby   = "IAC - Terraform"
  }

}

# SG (Security Group) for WebServer
resource "aws_security_group" "new_sg_web" {
  vpc_id      = aws_vpc.NewVpc.id
  name        = "sg_new_ssh"
  description = "Allow SSH - RDP - HTTP - DB "

  # Allow Ingress / inbound Of port 22 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 3389
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 3306
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 80
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  # Allow Ingress / inbound Of port 8080
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }
  # Allow egress / outbound of all ports 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "new_sg_web"
    Description = "Allow SSH - RDP - HTTP - DB"
    CreatedBy   = "IAC - Terraform"
  }
}

# EC2 Instance in Private Subnet
/* resource "aws_instance" "new_web" {
 ami                    = "ami-0574da719dca65348"
  instance_type          = "t2.micro"
  key_name               = "Ansible"
  subnet_id              = aws_subnet.new_public_subnet1.id
  vpc_security_group_ids = ["${aws_security_group.new_sg_web.id}"]#

  tags = {
    Name      = "new_web"
    CreatedBy = "IAC - Terraform"
    OSType    = "Linux - Ubuntu"
  }
} */

# EC2 Instance  in Public Subnet
resource "aws_instance" "new_web1" {
  ami                    = "ami-092694409ab038fa6"
  instance_type          = "t2.medium"
  key_name               = "Ansible"
  subnet_id              = aws_subnet.new_public_subnet1.id
  vpc_security_group_ids = ["${aws_security_group.new_sg_web.id}"]
  #user_data              = data.template_file.cb_web2_userdata.rendered

  tags = {
    Name      = "new_web"
    CreatedBy = "IAC - Terraform"
    OSType    = "Linux - Ubuntu 20.04"
  }
}
