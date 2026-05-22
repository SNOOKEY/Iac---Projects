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

