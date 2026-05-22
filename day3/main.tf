terraform {
  required_version = ">= 0.12"
}


resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-uniquewokkali-bucket-name-11111"
  

  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }

}

