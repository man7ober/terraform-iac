# define subnet
resource "aws_subnet" "my-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

# define internet gateway - modem
resource "aws_internet_gateway" "my-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# define route table - router
resource "aws_route_table" "my-rtb" {
  vpc_id = var.vpc_id

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
