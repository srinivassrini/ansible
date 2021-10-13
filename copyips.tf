resource "local_file" "webserverips" {
  content  = "[webservers]\n${aws_instance.webserver1.private_ip}\n${aws_instance.webserver2.private_ip}\n[dbserver]\n${aws_instance.webserver1.private_ip}"
  filename = "hosts"
}

resource "local_file" "dbendpoint1" {
  content  = "${aws_db_instance.rds.address}"
  filename = "endpoint"
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook demo_ansible.yml"
  }
  depends_on = [aws_db_instance.rds]
}