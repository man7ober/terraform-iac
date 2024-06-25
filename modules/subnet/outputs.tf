output "subnet" {
  value = [
    aws_subnet.my-subnet,
    aws_route_table.my-rtb
  ]
}
