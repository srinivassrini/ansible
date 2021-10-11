resource "local_file" "webserverips" {
  content  = "${aws_instance.webserver1.private_ip}\n${aws_instance.webserver2.private_ip}"
  filename = "hosts"
}