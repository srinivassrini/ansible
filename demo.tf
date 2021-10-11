provider "aws" {
	region = "us-east-2"
	access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
	}
	
	
	
	
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "first_az" {
	default = "us-east-2a"
	}
	
variable "second_az" {
	default = "us-east-2b"
	}
	
variable "key_name" {
    default = "ansible"
	}
		
variable "vpc_cidr" {
	default = "10.192.0.0/16"
	}
	
variable "publicsubnetcidr1" {
	default = "10.192.10.0/24"
	}

variable "privatesubnetcidr1" {
	default = "10.192.20.0/24"
	}
	
variable "privatesubnetcidr2" {
	default = "10.192.21.0/24"
	}
	
variable "publicsubnetcidr2" {
	default = "10.192.30.0/24"
	}

variable "privatesubnetcidr3" {
	default = "10.192.40.0/24"
	}
	
variable "privatesubnetcidr4" {
	default = "10.192.41.0/24"
	}

variable "instance_ami" {
	default = "ami-0443305dabd4be2bc"
	}
	
variable "bastion_ami" {
	default = "ami-00399ec92321828f5"
	}

variable "instance_type" {
	default = "t2.micro"
	}

variable "keyname" {
	default = "ansible"
	}

variable "instanceclass" {
	default = "db.t2.small"
	}
	
variable "admin_name" {
	default = "admin"
	}
	
variable "admin_pass" {
	default = "password"
	}
	
variable "vpc_peer" {
	default = "vpc-5d255236"
	}
	
variable "vpc_peer_cidr" {
	default = "172.31.0.0/16"
	}

variable "defaultroutetableid" {
	default = "rtb-5e2a1635"
	}
	
#VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "vpc"
  }
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW"
  }
}

#public subnet 1 in 2a az
resource "aws_subnet" "publicsubnet1" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = var.first_az
  cidr_block = var.publicsubnetcidr1
  tags = {
    Name = "publicsubnet1 (2a)"
  }
}

resource "aws_route_table" "publicroutetable1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "bastion publicroutetable (2a)"
  }
}

resource "aws_route" "publicroute" {
  route_table_id            = aws_route_table.publicroutetable1.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "publicroutetableassociation1" {
  subnet_id     = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.publicroutetable1.id
}

#Bastion SG
resource "aws_security_group" "bastion" {
	name = "Bastion SG"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
	Name = "Bastion SG"
	}
}

#Bastion server
resource "aws_instance" "bastionserver" {

  subnet_id              = aws_subnet.publicsubnet1.id
  ami                    = var.bastion_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
# install httpd (Linux 2 version)
sudo apt-get update
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update && sudo apt-get install ansible -y
echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA5LpBe4BDJfTyk2JJZ/5ixSl3b1mtt4Z/KA+PkxshKa48BLaG
WuKET3aiPHBxLOfIolRR6fuiXi/mJAnG/V2GnUUFMZgMwtjLY+Ybp2tighp8oaEh
sa4XexDOg14IhkxoRxNQJPZGLHrdbgh/fve1kajnhBatnkyESVsIvWPGsG4MOwri
Aa5kioDSArDvqv++OtzcyjjAFaoYOup6iGfuKH3RmZxJVr6PnMZt4L5WwgLmiDH5
xjyomxriu+2T8PGKeIaHAkgNQGyzcZfd5d0g+r9SxpfErsc4TvdoFyipslYF5BJK
kckq4rwgKlOx12o1lm81FQCOPKX7GOt4tumNlQIDAQABAoIBAFg30lvM65kvMYRQ
61kVz4iV5r/myc64LEEKR2kIlLDbx8BVmdph9YAklIxVHgGg4Exj0zg42rYTKWOK
9dnxAaOU5FztdTaNoVzFerMHAvaFOr6oRDOgnuPTZqNaWFVcEPgg5c9rwUMUnGT9
GBejeL9Wcv0KNiqQ/pDAcM2DNzYCcSuTLI1whTDYyklG/JeyRqWceXW3qnC0FIFU
oOiyO3EUTJFRbk1Hk7cYUY7AGMovl5YyithAU1eDbGTZ5O7Ef2IqfgTAg2562QvJ
Pg8+ysGsMy09WIj7Dklcl9kbR7X7sri/JH9D6J7kSX0m0oD9HoIUv6MObhz5AlAE
f7CnpqECgYEA+XrbF4x0UQWoRi+upAyLGhdjNlODaUXznfGRPwKoSBPZfOPmiCrN
xmNgVcmUwwpbLpJiDUXD/ONMe5O3D/XPjihPINSA+MCWLK5UKA16EJ/rM4OqUPzD
QCDsC2ZPbPHtlm9tJL2rqu3oNYfJ7bfkHEAdm1LY/KmdSKptP+dOwr0CgYEA6rSO
ds5r6J/Bbuijn0cVpjIWnrv4k2wkK2rUZOGLoYzkSANw1CdvV8auWWdjWb47/d1C
2n8pxPKr26d5y+6kDiGrnRQ9eNXcTdaTRAEIAUUTFowOE2g/teY/7us2tV7vG4Wu
cU6LwIXjlJMe2b90mm8b5VV7lkeZ2wszwVooz7kCgYEAlc8aZSeoaUbWZ18WpdgK
Z56HqwW3Ma4ZvkxjBc1Ys/+HaCGKO1ZIvsrJ/HnR5NUBMBQi4Ql1yRPMx6BKG0Fm
Y1z9Nx+kWrt68lW0n2CIXhdJq2NzELLXpFigpa/IHgmgu+cpSRjETx4RhKOHtEHq
rrQpky3Kst4/XnVIqUkC2JkCgYEAjdCBUFoTq6Bz8X7R9titxRj4v/rWDMXH6RAI
u9foVbna6YRitV4Kkd/z0wN8bWpbt13tGjbB10XF/9fm6QkNyZggqK3lItEd505i
9zEkVBgXm4UOsD1KWa+BK+ylxttQ4LFaoQ4TtUVxKIHonytm2jWOhnirTzd+SHMx
V4ARrskCgYEAiVTAPtspCqVfc3bdkK5t4y1virV2VJJ/ex5mGQ+vSwr4hXc+UA3s
HMDAOHl4VVHCxQKSAbNfALVi8jdCSwKxrA+Hu6Mw4UHyuwZnkJxpsaPW7aQ1hg2w
k9INwb52HairB4USB9kA6qw7vhts+v66Au46fqXZVUo7QEnS4TMEMc4=
-----END RSA PRIVATE KEY-----" > /etc/ansible/ansible.pem

yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from Bastion Server $(hostname -f)</h1>" > /var/www/html/index.html
EOF
  tags = {
	Name = "Bastion Server"
	}
}


#private subnet 1 in 2a az
resource "aws_subnet" "privatesubnet1" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone = var.first_az
  cidr_block = var.privatesubnetcidr1
  tags = {
    Name = "privatesubnet1 (2a)"
  }
}

resource "aws_route_table" "privateroutetable1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "webserver1 privateroutetable (2a)"
  }
}

resource "aws_route" "privateroute" {
  route_table_id            = aws_route_table.privateroutetable1.id
  destination_cidr_block    = "0.0.0.0/0"
  #instance_id = aws_instance.bastionserver.id
  nat_gateway_id  = aws_nat_gateway.natgateway.id
}

resource "aws_route" "peerroute" {
  route_table_id            = aws_route_table.privateroutetable1.id
  destination_cidr_block    = var.vpc_peer_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


resource "aws_route_table_association" "privateroutetableassociation1" {
  subnet_id     = aws_subnet.privatesubnet1.id
  route_table_id = aws_route_table.privateroutetable1.id
}

#Webserver SG 1
resource "aws_security_group" "web1" {
	name = "Webserver SG"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
	Name = "Webserver SG 1"
	}
}

#Webserver 1
resource "aws_instance" "webserver1" {

  subnet_id              = aws_subnet.privatesubnet1.id
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.web1.id,aws_security_group.bastion.id]
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from Webserver1 $(hostname -f)</h1>" > /var/www/html/index.html
EOF
  tags = {
	Name = "Web Server 1"
	}
}










#public subnet 1 in 2b az
resource "aws_subnet" "publicsubnet2" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = var.second_az
  cidr_block = var.publicsubnetcidr2
  tags = {
    Name = "publicsubnet1 (2b)"
  }
}

resource "aws_route_table" "publicroutetable2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "nat publicroutetable (2b)"
  }
}

resource "aws_route" "publicroute2" {
  route_table_id            = aws_route_table.publicroutetable2.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "publicroutetableassociation2" {
  subnet_id     = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.publicroutetable2.id
}

#elastic ip
resource "aws_eip" "eip" {
  vpc = true
   tags = {
	Name = "EIP"
	}
}

#nat gateway
resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publicsubnet2.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
	Name = "NAT"
	}
}


#private subnet 1 in 2b az
resource "aws_subnet" "privatesubnet3" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone = var.second_az
  cidr_block = var.privatesubnetcidr3
  tags = {
    Name = "privatesubnet3 (2b)"
  }
}

resource "aws_route_table" "privateroutetable3" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "webserver2 privateroutetable (2b)"
  }
}

resource "aws_route" "privateroute3" {
  route_table_id            = aws_route_table.privateroutetable3.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.natgateway.id
}

resource "aws_route" "peerroute2" {
  route_table_id            = aws_route_table.privateroutetable3.id
  destination_cidr_block    = var.vpc_peer_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route_table_association" "privateroutetableassociation3" {
  subnet_id     = aws_subnet.privatesubnet3.id
  route_table_id = aws_route_table.privateroutetable3.id
}

#Webserver SG 2
resource "aws_security_group" "web2" {
	name = "Webserver SG 2"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
	Name = "Webserver SG 2"
	}
}

#Webserver 1
resource "aws_instance" "webserver2" {

  subnet_id              = aws_subnet.privatesubnet3.id
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web2.id]
  key_name               = var.keyname
    user_data              = <<EOF
#!/bin/bash
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from Webserver2 $(hostname -f)</h1>" > /var/www/html/index.html
EOF
  tags = {
	Name = "Web Server 2"
	}
}








resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnet"
  subnet_ids = [aws_subnet.privatesubnet1.id, aws_subnet.privatesubnet3.id]
  tags = {
    Name = "dbsubnet"
  }
}

#Database SG
resource "aws_security_group" "dbsg" {
  vpc_id = aws_vpc.vpc.id
  name = "dbsg"
  description = "allow-mariadb"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web1.id, aws_security_group.web2.id] # allowing access from our example instance
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web1.id, aws_security_group.web2.id] # allowing access from our example instance
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "dbsg"
  }
}

#RDS DB
resource "aws_db_instance" "rds" {
  allocated_storage    = 5
  engine               = "mysql"
  instance_class       = var.instanceclass
  name                 = "myrdsdb"
  username             = var.admin_name
  password             = var.admin_pass
  skip_final_snapshot  = true
  availability_zone    = var.first_az
  vpc_security_group_ids = [aws_security_group.dbsg.id]
  db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
  tags = {
    Name = "myrdsdb"
  }
}




#ALB 1
resource "aws_lb" "alb1" {
  name               = "alb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web1.id,aws_security_group.web2.id,aws_security_group.bastion.id]
  subnets            = [aws_subnet.publicsubnet2.id,aws_subnet.publicsubnet1.id]
  tags = {
    Name = "alb 1"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
  condition {
    path_pattern {
      values = ["/webserver/*"]
    }
  }
}


resource "aws_lb_target_group" "tg1" {
  name     = "tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "tgattachment1" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tgattachment2" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}


#VPC Peering
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = aws_vpc.vpc.id
  vpc_id        = var.vpc_peer
  auto_accept   = true

  tags = {
    Name = "terra vpc peer"
  }
}

resource "aws_route" "defaultpeer" {
  route_table_id            = var.defaultroutetableid
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}