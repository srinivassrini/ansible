resource "local_file" "webserverips" {
  content  = "[webservers]\n${aws_instance.webserver1.private_ip}\n${aws_instance.webserver2.private_ip}\n[appservers]\n${aws_instance.appserver1.private_ip}\n${aws_instance.appserver2.private_ip}\n[dbservers]\n${aws_instance.appserver1.private_ip}"
  filename = "hosts"
}

resource "local_file" "dbendpoint1" {
  content  = "${aws_db_instance.rds.address}"
  filename = "endpoint"
}

resource "local_file" "dbendpoint_php" {
  content  = "<?php\n$endpoint='${aws_db_instance.rds.address}';\n$username='${aws_db_instance.rds.username}';\n$password='${aws_db_instance.rds.password}';\n$dbname='${aws_db_instance.rds.name}';\n$alb1='http://${aws_lb.alb1.dns_name}/flogin.php';\n$alb2_login='http://${aws_lb.alb2.dns_name}/login.php';\n$alb2_signup='http://${aws_lb.alb2.dns_name}/signup.php';\n?>"
  filename = "templates/endpoint.php"
}


resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook demo_ansible.yml"
  }
  depends_on = [aws_db_instance.rds,aws_instance.webserver1,aws_instance.webserver2,aws_instance.appserver1,aws_instance.appserver2]
}
