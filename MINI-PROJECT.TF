


provider "aws" {
  region = "us-east-1"
}

# 1.creat a vpc - 10.81.0.0/16

resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.81.0.0/16"

tags = {
    name = "prod_vpc"
 
}
}
  
  # 2.creating internet gateway

  resource "aws_internet_gateway" "prod_gw" {
    vpc_id = aws_vpc.prod_vpc.id

    tags = {
     names = "prod_gw"
    }
  }

# 3.create a custom Route table

resource "aws_route_table" "prod_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_gw.id
  }
}

# 4.create a subnet -- 10.81.3.0/24

resource "aws_subnet" "prod_sn" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.81.3.0/24"

  tags = {
    Name = "prod_sn"
  }
}

# 5.associate subnates with Route table

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.prod_sn.id
  route_table_id = aws_route_table.prod_rt.id
}

# 6. create security groups to allow all ports 22,80,443,or all ports, traffic

resource "aws_security_group" "prod_sg" {
  name        = "prod_web_sg"
  vpc_id      = aws_vpc.prod_vpc.id 

  # Inbound rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Inbound rule for HTTP (port 80)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule for HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod_sg"
  }
}

# 7.create a network interface with an ip in the subnet that was created in step 4 

resource "aws_network_interface" "prod_nic" {
  subnet_id       = aws_subnet.prod_sn.id
  private_ips     = ["10.81.3.33"]
  security_groups = [aws_security_group.prod_sg.id]

  
  tags = {
    names = "prod_nic"
  }
    }

    # 8.assign an elastic ip to the nework interface created in step 7

    resource "aws_eip" "prod_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.prod_nic.id
  associate_with_private_ip = "10.81.3.33"

  tags = {
    names = "prod_eip"
  }
    }

 # 9.create an ec2 server, launch application in it 

 resource "aws_instance" "prod" {
  ami = "ami-068c0051b15cdb816"
   region = "us-east-1"
   instance_type = "t2.micro"
   key_name = "terraform"
   count = 0
   user_data = file("ngnix_prod.sh")
    network_interface {
    network_interface_id = aws_network_interface.prod_nic.id
    device_index         = 0 
  }
  
   tags = {
    name = "prod"
   }
   
 }

 output "prod_server_public_ip" {
 value = "aws_instance.prod.public_ip"
 }