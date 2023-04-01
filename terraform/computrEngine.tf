resource "aws_vpc" "ntiervpc" {
    cidr_block = var.ntier_cidr

    tags = {
      "Name" = "ntier"
    }
  
}

resource "aws_subnet" "subnets" {
   
   count = length(var.ntier_subnet_zones)

   cidr_block = cidrsubnet(var.ntier_cidr, 8, count.index)
   availability_zone = var.ntier_subnet_zones[count.index]
   tags = {
      "Name" = var.ntier_subnet_tags[count.index]
    }
    vpc_id = aws_vpc.ntiervpc.id

    depends_on = [
      aws_vpc.ntiervpc
    ]
}

resource "aws_internet_gateway" "ntierig" {
  vpc_id = aws_vpc.ntiervpc.id

  tags = {
    "Name" = "ntier-ig"
  }

  depends_on = [
    aws_vpc.ntiervpc
  ]
  
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ntiervpc.id
  route = [ ]
  
  tags = {
    "Name" = "ntier-public"
  }

  depends_on = [
    aws_vpc.ntiervpc,
    aws_subnet.subnets  
  ]
}

resource "aws_route" "publicroute" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ntierig.id
}

resource "aws_route_table_association" "publicrtassociations" {
  count = length(var.dev_subnet_indexes)
  subnet_id = aws_subnet.subnets[var.dev_subnet_indexes[count.index]].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "test" {
  name = "openhttp"
  description = "Open http and ssh"
  vpc_id = aws_vpc.ntiervpc.id

  tags = {
    "Name" = "Openhttp"
  }
  depends_on = [
    aws_vpc.ntiervpc,
    aws_subnet.subnets
  ]

}

resource "aws_security_group_rule" "websghttp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test.id
  
  
}

resource "aws_security_group_rule" "associate" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test.id

  
  
}
resource "aws_key_pair" "keypair" {
    key_name        = "aws"
    public_key      = file("~/.ssh/id_rsa.pub")
   
}

resource "aws_instance" "terraformserver" {
  ami = "ami-02eb7a4783e7e9317" 
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.test.id]
  subnet_id = aws_subnet.subnets[0].id

  depends_on = [
    aws_vpc.ntiervpc,
    aws_subnet.subnets,
    aws_security_group.test,
    aws_route_table.public

  ]
  tags = {
    "name" = "computeEngine"
  }
}