
# Cloud provider  aws,azure, gcp

provider "aws" {   
}

# 1.Create custom vpc 
resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
      name = "production"
    }

}
#  2.Internet gateway for vpc
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.first-vpc.id

   tags = {
    name = "pro-gw"
   }
}

# 3.Creating a route table 

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "pro"
  }
}

# $.create a subnet within specific vpc
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Subnets assoiation to route table
 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create security group and specify inbound and outbound traffic
resource "aws_security_group" "allow_web" {
  name        = "allow_web-traffic"
  description = "Allow  inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Creating a network interface 

resource "aws_network_interface" "pro-net" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# 8. Elastic ip for public access
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.pro-net.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}


# Output just for showing the parameter of resources

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# 9.Create ubuntu server (ec2 instance with apache )

resource "aws_instance" "ec2-t" {

    ami="ami-01a4f99c4ac11b03c"
    instance_type = "t2.micro"
    availability_zone="ap-south-1a"
    key_name = "new-key"
  
    network_interface {
      device_index=0
      network_interface_id=aws_network_interface.pro-net.id
    }

    user_data = <<-EOF
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo first web server > /var/www/html/index.html'      
                EOF

    tags = {
        name ="web-server1"
    }            
}