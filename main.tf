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

# define subnet module
module "myapp-subnet" {
  source            = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone        = var.avail_zone
  env_prefix        = var.env_prefix
  vpc_id            = aws_vpc.my-vpc.id
}

# define webserver module
module "myapp-server" {
  source              = "./modules/webserver"
  public_key_location = var.public_key_location
  instance_type       = var.instance_type
  avail_zone          = var.avail_zone
  env_prefix          = var.env_prefix
  vpc_id              = aws_vpc.my-vpc.id
  subnet_id           = module.myapp-subnet.subnet[0].id
}
