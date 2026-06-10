variable "primary"{
     default = "eu-north-1"
}

variable "secondary"{
     default = "eu-west-1"
}

variable "primary_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  default = "10.0.0.0/16"
}