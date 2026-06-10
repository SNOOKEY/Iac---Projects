provider "aws" {
  region = "eu-north-1"
  alias = "primary"
}

provider "aws" {
  region = "us-east-1"
  alias = "secondary"
}




resource "aws_vpc" "primary_vpc" {
  cidr_block       = var.primary_vpc_cidr
  instance_tenancy = "default"
  provider         = aws.primary
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "primary-VPC-${var.primary}"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block       = var.secondary_vpc_cidr
  instance_tenancy = "default"
  provider         = aws.secondary
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "secondary-VPC-${var.secondary}"
  }
}

resource "aws_subnet" "primary_subnet" {
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = var.primary_vpc_cidr
  availability_zone = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "primary-subnet-${var.primary}"
  }
}

resource "aws_subnet" "secondary_subnet" {
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = var.secondary_vpc_cidr
  availability_zone = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "secondary-subnet-${var.secondary}"
  }
}


resource "aws_internet_gateway" "primary_igw" {
  vpc_id = aws_vpc.primary_vpc.id
  provider = aws.primary

  tags = {
    Name = "primary-igw-${var.primary}"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  vpc_id = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
    Name = "secondary-igw-${var.secondary}"
  }
}

resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id
  provider = aws.primary
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
    }

  tags = {
    Name = "primary-route-table-${var.primary}"
  }
}

resource "aws_route_table" "secondary_route_table" {
  vpc_id = aws_vpc.secondary_vpc.id
  provider = aws.secondary
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
    }   

    tags = {
    Name = "secondary-route-table-${var.secondary}"
  }     

}

resource "aws_route_table_association" "primary_route_table_association" {
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
  provider       = aws.primary
}

resource "aws_route_table_association" "secondary_route_table_association" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
  provider       = aws.secondary
}

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider = aws.primary
  peer_region   = var.secondary
  peer_vpc_id   = aws_vpc.secondary_vpc.id
  vpc_id        = aws_vpc.primary_vpc.id

  tags = {
    Name = "vpc-peering-${var.primary}-${var.secondary}"
  }
}

resource "aws_vpc_peering_connection" "secondary_to_primary" {
  provider = aws.secondary
  peer_region   = var.primary
  peer_vpc_id   = aws_vpc.primary_vpc.id
  vpc_id        = aws_vpc.secondary_vpc.id

  tags = {
    Name = "vpc-peering-${var.secondary}-${var.primary}"
  }

}       

resource "aws_route" "primary_to_secondary_route" {
  provider = aws.primary
  route_table_id         = aws_route_table.primary_route_table.id
  destination_cidr_block = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection.primary_to_secondary]
}

resource "aws_route" "secondary_to_primary_route" {
  provider = aws.secondary
  route_table_id         = aws_route_table.secondary_route_table.id
  destination_cidr_block = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.secondary_to_primary.id

  depends_on = [aws_vpc_peering_connection.secondary_to_primary]
}





    

resource "aws_security_group" "primary_sg" {
  name        = "primary-sg-${var.primary}"
  description = "Security group for primary VPC"
  vpc_id      = aws_vpc.primary_vpc.id
  provider    = aws.primary

  ingress {
    description = "Allow SSH from anywhere "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = " ICMP from secondary VPC"    
    from_port   = -1
    to_port     = -1            
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  } 
  ingress {
    description = "Allow all traffic from secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}   

resource "aws_security_group" "secondary_sg" {
  name        = "secondary-sg-${var.secondary}"
  description = "Security group for secondary VPC"
  vpc_id      = aws_vpc.secondary_vpc.id
  provider    = aws.secondary

  ingress {
    description = "Allow SSH from anywhere "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    description = " ICMP from primary VPC"  
    from_port   = -1            
    to_port     = -1            
    protocol    = "icmp"    
    cidr_blocks = [var.primary_vpc_cidr]
    }

    ingress {
    description = "Allow all traffic from primary VPC"
    from_port   = 0 
    to_port     = 65535
    protocol    = "tcp"             
    cidr_blocks = [var.primary_vpc_cidr]
    }   

    egress {     
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"]
    }   


}

resource "aws_instance" "primary_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.primary_subnet.id
  security_groups = [aws_security_group.primary_sg.name]
  provider      = aws.primary

  tags = {
    Name = "primary-instance-${var.primary}"
 
  }

  depends_on = [aws_vpc_peering_connection.primary_to_secondary]
}


resource "aws_instance" "secondary_instance" {
  ami           = data.aws_ami.amazon_linux_secondary.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.secondary_subnet.id
  security_groups = [aws_security_group.secondary_sg.name]
  provider      = aws.secondary

  tags = {
    Name = "secondary-instance-${var.secondary}"
  }

  depends_on = [aws_vpc_peering_connection.secondary_to_primary]
}