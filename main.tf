# define variables
variable "access_key" {}
variable "secret_key" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "private_key_location" {}

# define cloud provider
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# define vpc
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# define subnet
resource "aws_subnet" "my-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

# define internet gateway - modem
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# define route table - router
resource "aws_route_table" "my-rtb" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

# define subnet association
resource "aws_route_table_association" "my-rtb-subnet" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-rtb.id
}

# define security group - firewall
resource "aws_security_group" "my-sg" {
  name   = "my-sg"
  vpc_id = aws_vpc.my-vpc.id

  # incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

# define ami 
data "aws_ami" "latest-amazon-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# define key-pair
resource "aws_key_pair" "ssh-key" {
  key_name   = "my-key-pair"
  public_key = file(var.public_key_location)
}

# define ec2 instances
resource "aws_instance" "my-instance" {
  ami                         = data.aws_ami.latest-amazon-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.my-subnet.id
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  # make connection to ec2 instance
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  # type 1 - connect via ssh using terraform
  provisioner "remote-exec" {
    script = "entry-script.sh"
  }

  # type 2 - locally executes
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
  }

  # type 3 - copy files / dir from local to remote
  provisioner "file" {
    source      = "entry-script.sh"
    destination = "/home/ec2-user/entry-script-ec2.sh"
  }

  tags = {
    Name = "${var.env_prefix}-instance"
  }
}

# console aws ids
output "aws-ids" {
  value = [
    aws_vpc.my-vpc.id,
    aws_subnet.my-subnet.id,
    aws_route_table.my-rtb.id,
    data.aws_ami.latest-amazon-image.id,
    aws_instance.my-instance.id
  ]
}
