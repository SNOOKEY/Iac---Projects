terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

variable "buckets_names" {
  type        = list(string)
  default     = ["my-tf-test-wokkali-bucket-10121", "my-tf-test-wokkali-bucket-1013"]
  description = "description"
}


resource "aws_s3_bucket" "tf_test_bucket" {
  count = length(var.buckets_names)
  bucket = var.buckets_names[count.index]
 
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "tf_test_bucket_set" {
  for_each = var.buckets_names_set
  bucket   = each.value
 
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
variable "buckets_names_set" {
  type        = set(string)
  default     = ["my-tf-test-wokkali-bucket-101211", "my-tf-test-wokkali-bucket-101311"]
  description = "description"
}


variable bucket_names {
  type        = string
  default     = ""
  description = "description"
}

output "ec2_name" {
  value = aws_instance.example.tags["Name"]
  description = "The name of the EC2 instance"
}

resource "aws_instance" "example" {
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
 
 
tags = {
  Name = "ex-instance"
}
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "description"



validation {
  condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 12 
  error_message = "instance_type must be under 12 characters and more than 2 characters."
}
}

variable "instance_type_generation"{
  type = string 
  description = "must be t2 or t3"
validation{
  condition = can (regex("^(t2|t3)\\..*$", var.instance_type_generation))
  error_message = "instance_type_generation must be t2 or t3"
}

}

locals {
  
    primary = ["eu-north-1","eu-west-1"]
    secondary = ["eu-west-1","us-east-1"]
  combined_region = concat(local.primary, local.secondary) 
     final_region = toset(local.combined_region)
}

output "instance_region" {
  value = aws_instance.example.region
  description = "The region of the EC2 instance"
  
}