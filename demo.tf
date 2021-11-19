provider "aws" {
	region = "ap-south-1"
	access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
	}
	
	
	####VARIABLES#####
	
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {
	default = "ap-south-1"
	}

#AZ
variable "first_az" {
	default = "ap-south-1a"
	}
	
variable "second_az" {
	default = "ap-south-1b"
	}
		
		
#VPC & SUBNETS CIDR
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


#EC2 INSTANCE	
variable "instance_ami" {
	default = "ami-0f1fb91a596abf28d"
	}
	
variable "instance_ami_ecs" {
	default = "ami-000e4b3f0c9f06ffb"
	}
	
variable "instance_type" {
	default = "t2.micro"
	}

variable "keyname" {
	default = "ecs"
	}


#RDS
variable "rds_name" {
	default = "myrdsdb"
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
	
	
#ECS 
variable "clustername1" {
	default = "cluster1"
	}
	
variable "taskfamily1" {
	default = "task1"
	}
	
variable "ecsservicename1" {
	default = "service1"
	}
	
variable "clustername2" {
	default = "cluster2"
	}
	
variable "taskfamily2" {
	default = "task2"
	}
	
variable "ecsservicename2" {
	default = "service2"
	}

variable "clustername3" {
	default = "cluster3"
	}
	
variable "taskfamily3" {
	default = "task3"
	}
	
variable "ecsservicename3" {
	default = "service3"
	}
	
	variable "clustername4" {
	default = "cluster4"
	}
	
variable "taskfamily4" {
	default = "task4"
	}
	
variable "ecsservicename4" {
	default = "service4"
	}

#DOCKER
variable "docker_build_name" {
	default = "myphpimage1"
	}
	
variable "docker_build_name1" {
	default = "myphpimage2"
	}
	
#Peering
variable "vpc_peer" {
	default = "vpc-003cfa21cbe7f46ec"
	}
	
variable "vpc_peer_cidr" {
	default = "172.31.0.0/16"
	}

variable "defaultroutetableid" {
	default = "rtb-0c5fa0dededce9a3e"
	}
	
	
	
#ROLE	
variable "ec2role" {
	default = "ecsinstanceroles"
	}	
	
resource "aws_iam_role" "ecstask" {
  name = "ecstask"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})

  tags = {
    tag-key = "ecstask"
  }
}	

resource "aws_iam_policy" "ecstaskpolicy" {
  name        = "ecstaskpolicy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecstask-attach" {
  role       = aws_iam_role.ecstask.name
  policy_arn = aws_iam_policy.ecstaskpolicy.arn
}

#EC2 ROLE
resource "aws_iam_role" "ec2role" {
  name = var.ec2role

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
}	
	
resource "aws_iam_policy" "ec2rolepolicy" {
  name        = "ec2rolepolicy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ec2role-attach" {
  role       = aws_iam_role.ec2role.name
  policy_arn = aws_iam_policy.ec2rolepolicy.arn
}

resource "aws_iam_instance_profile" "roleprofilr" {
  name = var.ec2role
  role = aws_iam_role.ec2role.name
}
	
	
#ECS SERVICE ROLE
resource "aws_iam_role" "ecsservice" {
  name = "ecsservice"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})

  tags = {
    tag-key = "ecsservice"
  }
}	

resource "aws_iam_policy" "ecsservicepolicy" {
  name        = "ecsservicepolicy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:Describe*",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:RegisterTargets"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecsservice-attach" {
  role       = aws_iam_role.ecsservice.name
  policy_arn = aws_iam_policy.ecsservicepolicy.arn
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
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
# install httpd (Linux 2 version)
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

#ecs SG 1
resource "aws_security_group" "ecs1" {
	name = "ecs SG 1"
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
	Name = "ecs1"
	}
}


#Webserver 1
resource "aws_instance" "webserver1" {

  subnet_id              = aws_subnet.privatesubnet1.id
  ami                    = var.instance_ami_ecs
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.ecs1.id,aws_security_group.bastion.id]
  iam_instance_profile   = var.ec2role
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=cluster1 >> /etc/ecs/ecs.config

EOF
  tags = {
	Name = "Web Server 1"
	}
	depends_on = [aws_ecs_service.service1]
}


#ECS CLUSTER
resource "aws_ecs_cluster" "cluster1" {
  name = var.clustername1

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#ECS TASK DEFINITION
resource "aws_ecs_task_definition" "taskdefinition1" {
  family = var.taskfamily1
  execution_role_arn       = aws_iam_role.ecstask.arn
  task_role_arn = aws_iam_role.ecstask.arn
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "latest"
      image     = aws_ecr_repository.ecr.repository_url
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
	depends_on = [null_resource.dockerpush]
}

#ECS SERVICE
resource "aws_ecs_service" "service1" {
  name            = var.ecsservicename1
  cluster         = aws_ecs_cluster.cluster1.id
  iam_role        = aws_iam_role.ecsservice.arn
  scheduling_strategy = "REPLICA"
  task_definition = aws_ecs_task_definition.taskdefinition1.arn
  desired_count   = 1
  launch_type = "EC2"


  load_balancer {
    target_group_arn = aws_lb_target_group.tg1.arn
    container_name   = "latest"
    container_port   = 80
  }
  depends_on = [null_resource.dockerpush]
}





#private subnet 2 in 2a az
resource "aws_subnet" "privatesubnet2" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone = var.first_az
  cidr_block = var.privatesubnetcidr2
  tags = {
    Name = "privatesubnet2 (2a)"
  }
}

resource "aws_route_table" "privateroutetable2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "appserver1 privateroutetable2 (2a)"
  }
}

resource "aws_route" "privateroute2" {
  route_table_id            = aws_route_table.privateroutetable2.id
  destination_cidr_block    = "0.0.0.0/0"
  #instance_id = aws_instance.webserver1.id
  nat_gateway_id  = aws_nat_gateway.natgateway.id
}

resource "aws_route" "peerroute2" {
  route_table_id            = aws_route_table.privateroutetable2.id
  destination_cidr_block    = var.vpc_peer_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route_table_association" "privateroutetableassociation2" {
  subnet_id     = aws_subnet.privatesubnet2.id
  route_table_id = aws_route_table.privateroutetable2.id
}

#ECS SG 2
resource "aws_security_group" "ecs2" {
	name = "ecs SG 2"
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
	Name = "ecs2"
	}
}

#APPSERVER 1
resource "aws_instance" "appserver1" {

  subnet_id              = aws_subnet.privatesubnet2.id
  ami                    = var.instance_ami_ecs
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.ecs2.id,aws_security_group.ecs1.id,aws_security_group.bastion.id]
  iam_instance_profile   = var.ec2role
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=cluster2 >> /etc/ecs/ecs.config

EOF
  tags = {
	Name = "App Server 1"
	}
	depends_on = [aws_ecs_service.service2]
}


#ECS CLUSTER
resource "aws_ecs_cluster" "cluster2" {
  name = var.clustername2

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#ECS TASK DEFINITION
resource "aws_ecs_task_definition" "taskdefinition2" {
  family = var.taskfamily2
  execution_role_arn       = aws_iam_role.ecstask.arn
  task_role_arn = aws_iam_role.ecstask.arn
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "latest"
      image     = aws_ecr_repository.ecr1.repository_url
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
	depends_on = [null_resource.dockerpush1]
}

#ECS SERVICE
resource "aws_ecs_service" "service2" {
  name            = var.ecsservicename2
  cluster         = aws_ecs_cluster.cluster2.id
  iam_role        = aws_iam_role.ecsservice.arn
  scheduling_strategy = "REPLICA"
  task_definition = aws_ecs_task_definition.taskdefinition2.arn
  desired_count   = 1
  launch_type = "EC2"


  load_balancer {
    target_group_arn = aws_lb_target_group.tg2.arn
    container_name   = "latest"
    container_port   = 80
  }
  depends_on = [null_resource.dockerpush1]
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

resource "aws_route" "peerroute3" {
  route_table_id            = aws_route_table.privateroutetable3.id
  destination_cidr_block    = var.vpc_peer_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route_table_association" "privateroutetableassociation3" {
  subnet_id     = aws_subnet.privatesubnet3.id
  route_table_id = aws_route_table.privateroutetable3.id
}

#ecs SG 3
resource "aws_security_group" "ecs3" {
	name = "ecs SG 3"
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
	Name = "ecs3"
	}
}

#Webserver 2
resource "aws_instance" "webserver2" {

  subnet_id              = aws_subnet.privatesubnet3.id
  ami                    = var.instance_ami_ecs
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.ecs3.id]
  iam_instance_profile   = var.ec2role
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=cluster3 >> /etc/ecs/ecs.config

echo "<h1>Hello World from Webserver2 $(hostname -f)</h1>" > /var/www/html/index.html
EOF
  tags = {
	Name = "Web Server 2"
	}
	depends_on = [aws_ecs_service.service3]
}


#ECS CLUSTER
resource "aws_ecs_cluster" "cluster3" {
  name = var.clustername3

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#ECS TASK DEFINITION
resource "aws_ecs_task_definition" "taskdefinition3" {
  family = var.taskfamily3
  execution_role_arn       = aws_iam_role.ecstask.arn
  task_role_arn = aws_iam_role.ecstask.arn
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "latest"
      image     = aws_ecr_repository.ecr.repository_url
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
	depends_on = [null_resource.dockerpush]
}

#ECS SERVICE
resource "aws_ecs_service" "service3" {
  name            = var.ecsservicename3
  cluster         = aws_ecs_cluster.cluster3.id
  iam_role        = aws_iam_role.ecsservice.arn
  scheduling_strategy = "REPLICA"
  task_definition = aws_ecs_task_definition.taskdefinition3.arn
  desired_count   = 1
  launch_type = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg1.arn
    container_name   = "latest"
    container_port   = 80
  }
  depends_on = [null_resource.dockerpush]
}




#private subnet 2 in 2b az
resource "aws_subnet" "privatesubnet4" {
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  availability_zone = var.second_az
  cidr_block = var.privatesubnetcidr4
  tags = {
    Name = "privatesubnet4 (2b)"
  }
}

resource "aws_route_table" "privateroutetable4" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "appserver2 privateroutetable2 (2b)"
  }
}

resource "aws_route" "privateroute4" {
  route_table_id            = aws_route_table.privateroutetable4.id
  destination_cidr_block    = "0.0.0.0/0"
  #instance_id = aws_instance.webserver2.id
  nat_gateway_id  = aws_nat_gateway.natgateway.id
}

resource "aws_route" "peerroute4" {
  route_table_id            = aws_route_table.privateroutetable4.id
  destination_cidr_block    = var.vpc_peer_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route_table_association" "privateroutetableassociation4" {
  subnet_id     = aws_subnet.privatesubnet4.id
  route_table_id = aws_route_table.privateroutetable4.id
}


#ECS SG 4
resource "aws_security_group" "ecs4" {
	name = "ecs SG 4"
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
	Name = "ecs4"
	}
}

#APPSERVER 2
resource "aws_instance" "appserver2" {

  subnet_id              = aws_subnet.privatesubnet4.id
  ami                    = var.instance_ami_ecs
  instance_type          = var.instance_type
  security_groups        = [aws_security_group.ecs4.id,aws_security_group.ecs3.id]
  iam_instance_profile   = var.ec2role
  key_name               = var.keyname
  user_data              = <<EOF
#!/bin/bash
echo ECS_CLUSTER=cluster4 >> /etc/ecs/ecs.config

EOF
  tags = {
	Name = "App Server 2"
	}
	depends_on = [aws_ecs_service.service2]
}


#ECS CLUSTER
resource "aws_ecs_cluster" "cluster4" {
  name = var.clustername4

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#ECS TASK DEFINITION
resource "aws_ecs_task_definition" "taskdefinition4" {
  family = var.taskfamily4
  execution_role_arn       = aws_iam_role.ecstask.arn
  task_role_arn = aws_iam_role.ecstask.arn
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "latest"
      image     = aws_ecr_repository.ecr1.repository_url
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
	depends_on = [null_resource.dockerpush1]
}

#ECS SERVICE
resource "aws_ecs_service" "service4" {
  name            = var.ecsservicename4
  cluster         = aws_ecs_cluster.cluster4.id
  iam_role        = aws_iam_role.ecsservice.arn
  scheduling_strategy = "REPLICA"
  task_definition = aws_ecs_task_definition.taskdefinition4.arn
  desired_count   = 1
  launch_type = "EC2"


  load_balancer {
    target_group_arn = aws_lb_target_group.tg2.arn
    container_name   = "latest"
    container_port   = 80
  }
  depends_on = [null_resource.dockerpush1]
}









#DB SUBNET
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnet"
  subnet_ids = [aws_subnet.privatesubnet2.id, aws_subnet.privatesubnet4.id]
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
    cidr_blocks = ["0.0.0.0/0"] # allowing access from our example instance
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allowing access from our example instance
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
  identifier           = var.rds_name
  allocated_storage    = 5
  engine               = "mysql"
  instance_class       = var.instanceclass
  name                 = "myrdsdb"
  username             = var.admin_name
  password             = var.admin_pass
  skip_final_snapshot  = true
  availability_zone = var.first_az
  vpc_security_group_ids = [aws_security_group.dbsg.id,aws_security_group.ecs2.id,aws_security_group.ecs4.id]
  db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
  tags = {
    Name = "myrdsdb"
  }
}

#alb SG 1
resource "aws_security_group" "alb1" {
	name = "alb SG 1"
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
	Name = "alb1"
	}
}

#ALB 1
resource "aws_lb" "alb1" {
  name               = "alb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb1.id]
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

#alb SG 2
resource "aws_security_group" "alb2" {
	name = "alb SG 2"
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
	Name = "alb2"
	}
}

#ALB 2
resource "aws_lb" "alb2" {
  name               = "alb2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb2.id,aws_security_group.alb1.id]
  subnets            = [aws_subnet.publicsubnet2.id,aws_subnet.publicsubnet1.id]
  tags = {
    Name = "alb 2"
  }
}

resource "aws_lb_listener" "listener2" {
  load_balancer_arn = aws_lb.alb2.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg2.arn
  }
}

resource "aws_lb_listener_rule" "static2" {
  listener_arn = aws_lb_listener.listener2.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg2.arn
  }
  condition {
    path_pattern {
      values = ["/appserver/*"]
    }
  }
}

resource "aws_lb_target_group" "tg2" {
  name     = "tg2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "tgattachment3" {
  target_group_arn = aws_lb_target_group.tg2.arn
  target_id        = aws_instance.appserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tgattachment4" {
  target_group_arn = aws_lb_target_group.tg2.arn
  target_id        = aws_instance.appserver2.id
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
