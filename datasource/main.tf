resource "aws_instance" "example" {
  ami           = data.aws_ami.example.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.example.id
 }



data "aws_vpc" "vpc_name" {
  filter {
    name   = "tag:Name"
    values = ["project-vpc"]
  }
}

data aws_subnet "example" {
  filter {
    name   = "tag:Name"
    values = ["project-subnet-private1-eu-north-1a"]
   }  
    vpc_id = data.aws_vpc.vpc_name.id   
   }
   
   data "aws_ami" "example" {
   
     owners      = ["amazon"]
      most_recent = true
    filter {
      name   = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }
  }          