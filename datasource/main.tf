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


  data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "example" {}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-terraform-2024"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id

  access_control_policy {
    grant {
      grantee {
        id   = data.aws_cloudfront_log_delivery_canonical_user_id.example.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
  depends_on = [aws_s3_bucket_ownership_controls.example]
}