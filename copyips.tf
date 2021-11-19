#DOCKER 1

resource "local_file" "dbendpoint_php" {
  content  = "<?php\n$endpoint='${aws_db_instance.rds.address}';\n$username='${aws_db_instance.rds.username}';\n$password='${aws_db_instance.rds.password}';\n$dbname='${aws_db_instance.rds.name}';\n$alb1='http://${aws_lb.alb1.dns_name}/flogin.php';\n$alb1_login='http://${aws_lb.alb1.dns_name}/flogin.php';\n$alb2_login='http://${aws_lb.alb2.dns_name}/login.php';\n$alb2_signup='http://${aws_lb.alb2.dns_name}/signup.php';\n?>"
  filename = "docker/endpoint.php"
}

resource "null_resource" "ecrlogin" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS  --password-stdin ${aws_ecr_repository.ecr.repository_url}"
	working_dir = "docker/"
  }
  depends_on = [aws_ecr_repository.ecr]
}

resource "null_resource" "dockerbuild" {
  provisioner "local-exec" {
    command = "docker build -t ${var.docker_build_name} ."
	working_dir = "docker/"
  }
  depends_on = [aws_db_instance.rds]
}

resource "null_resource" "dockertag" {
  provisioner "local-exec" {
    command = "docker tag ${var.docker_build_name} ${aws_ecr_repository.ecr.repository_url}"
	working_dir = "docker/"
  }
  depends_on = [null_resource.dockerbuild]
}

resource "null_resource" "dockerpush" {
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.ecr.repository_url}"
	working_dir = "docker/"
  }
  depends_on = [null_resource.dockertag]
}

resource "aws_ecr_repository" "ecr" {
  name                 = "ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
	Name = "ecr"
	}
}



#DOCKER 2

resource "local_file" "dbendpoint_php1" {
  content  = "<?php\n$endpoint='${aws_db_instance.rds.address}';\n$username='${aws_db_instance.rds.username}';\n$password='${aws_db_instance.rds.password}';\n$dbname='${aws_db_instance.rds.name}';\n$alb1='http://${aws_lb.alb1.dns_name}/flogin.php';\n$alb1_login='http://${aws_lb.alb1.dns_name}/flogin.php';\n$alb2_login='http://${aws_lb.alb2.dns_name}/login.php';\n$alb2_signup='http://${aws_lb.alb2.dns_name}/signup.php';\n?>"
  filename = "docker2/endpoint.php"
}

resource "null_resource" "ecrlogin1" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS  --password-stdin ${aws_ecr_repository.ecr1.repository_url}"
	working_dir = "docker2/"
  }
  depends_on = [aws_ecr_repository.ecr1]
}

resource "null_resource" "dockerbuild1" {
  provisioner "local-exec" {
    command = "docker build -t ${var.docker_build_name1} ."
	working_dir = "docker2/"
  }
  depends_on = [aws_db_instance.rds]
}

resource "null_resource" "dockertag1" {
  provisioner "local-exec" {
    command = "docker tag ${var.docker_build_name1} ${aws_ecr_repository.ecr1.repository_url}"
	working_dir = "docker2/"
  }
  depends_on = [null_resource.dockerbuild1]
}

resource "null_resource" "dockerpush1" {
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.ecr1.repository_url}"
	working_dir = "docker2/"
  }
  depends_on = [null_resource.dockertag1]
}

resource "aws_ecr_repository" "ecr1" {
  name                 = "ecr1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
	Name = "ecr1"
	}
}


###ANSIBLE###
resource "local_file" "webserverips" {
  content  = "[webservers]\n${aws_instance.webserver1.private_ip}\n${aws_instance.webserver2.private_ip}\n[appservers]\n${aws_instance.appserver1.private_ip}\n${aws_instance.appserver2.private_ip}\n[dbservers]\n${aws_instance.appserver1.private_ip}"
  filename = "hosts"
}

resource "local_file" "dbenpoint1" {
  content = "endpoint: ${aws_db_instance.rds.address}\nusername: ${aws_db_instance.rds.username}\npassword: ${aws_db_instance.rds.password}\ndbname: ${aws_db_instance.rds.name}"
  filename = "db_vars.yml"
}


resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook demo_ansible.yml"
  }
  depends_on = [aws_db_instance.rds,aws_instance.webserver1,aws_instance.webserver2,aws_instance.appserver1,aws_instance.appserver2]
}