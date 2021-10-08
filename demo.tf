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
MIIEowIBAAKCAQEAhcw5tGvowfBVXvgNT1/BVJAq1ciVgGywFVSbAXAuu3pIkVPK
bi9e1cnJdBuJ2rw0mTYKIge0o8EIS4Q3oE35Ox2GhuVR/bPH7IMPr4s1rSCguUoQ
uXAmzdPq09Ndu59QNHfzvWeYfVqgIAJzbz4TuMBfFw7vrJs0FjHc1iSU9d3vfK+u
du7DPEAuJ9QEXp10PJXNF6gz0Pvew1ztbEmpvv8YJ1EHWeofNZrAZwEXFTB0ILxt
0pzTZgD6UKqdjtRDArRtqEwTC0QYEE5bE4yB9swmp+eUQDlKu+2vzTcQqKMoic4X
tUXlpmc6ZbFg07X5IOki5RDIOzxRHVAbPtmP8wIDAQABAoIBAF7EZz7ei68KHj20
7iCBTzspHd3sQ9ABq7qAAYZEQiVyGIIu2huvG7nLQhAmDT9LvOmj+Atgb9bou4pZ
bNjzQYtYf1d+h9NtijaAIhURQgSNLqnuxufBgwqYhiRg+mwRDEsNhytpe/2VugLS
GZb6Xhem0fNQFfyotXze9m8K3CNEd9VVVJpBQpRMF8VQu00980UAxroes8na0aXS
0fx8DrybWiOFPTYpHDxYkjYNnmXhr9jFUwMEbPTJWGw52+/MwKFuFBW7eCrjxAf9
0LF2R/+/q3bAsAhnw5RSgYG491Nn6gKw3FizOq7X88wcwPAVVuu2vo3ezNJrFbVl
WV1DjjECgYEAukGbKDdV0CWTyEAdXvoNHZFL/L7lg9FaPUFA8nypHV/F1kmLxk0/
prADD7BQ62jRQD3en8Nd2+uJ0WEWheyKOAMilg+oDPBEMaYQg/ZZLLE519Du9HRJ
r5WgWIab27eXAqMAyU8MHo+WbtEj4Vq/uB7TG3piySZrwCIP5JtBgbsCgYEAt+X7
qzIR6R1JpuQ1a8zNFrqIEB32gFLv9oM8vuuZ2K3bFbg0tTcCFzUbohhxMrJYGdNL
84xsMfrrNeX/VfXs+EB7jw2fGXpFdJkeqQpVerUR23mYnt00WbPtKRplQ7VrCsUg
0cYu59H1IUK9jLnVSQx3k5ZwaYv+d4K3DTZuSykCgYBCDoCDq9RgZONbsvl3tMEw
ClbjxaRKstYJQXpSRcoIo+3bSOwsoTsA2A3N459fTiZgXVD2YmiIVankO0Wsq659
nQcIJ3dXV2MoJJhY5ObNhfFYzD3jLtbvUeazXtIqA5uoEL13p/RJZm1Y0g2in/e8
yhne9fHRGzI9yxbN4g5CfwKBgQCS/8j74OtGP34XZQZ65FvwVizbTUg07ZcZo3BU
YPo6pUaihvvC+3S1XmN3YDhkQQGBq1BkH5SBI0UPcYl4ijvheZILGOVbtUx91sQW
dcc8bi8XFIz2OHZXWicymwHlbMhi9I62gMgP0No0uyfPrOCcItYW6MN0603+9EMk
0aS6eQKBgCgF4DBcbiCWxqcIGlbBVEkmueVbaVbgDtqh3PeKJwTT6L0DOOcRhxSL
d/OZ3t+hWSJzEvXtKfQ5cDLkYMydlqEIab//Kkq6exOmslISEonL1IFGfkPUhtjx
EHgdrdVgvEHffIDHAN7x7G0IAi7By5grt30rWxZ7DKnb8bs/ZSZe
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




