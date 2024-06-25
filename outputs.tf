# print aws ids
output "aws-ids" {
  value = [
    aws_vpc.my-vpc.id,                # vpc id
    module.myapp-subnet.subnet[0].id, # subnet id
    module.myapp-subnet.subnet[1].id, # route table id
    module.myapp-server.webserver[0], # ami id
    module.myapp-server.webserver[1]  # instance id
  ]
}
