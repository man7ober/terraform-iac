output "webserver" {
  value = [
    aws_instance.my-instance.ami,
    aws_instance.my-instance.id,
  ]
}
