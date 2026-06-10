variable "primary"{
     default = "us-east-1"
}

variable "secondary"{
     default = "us-west-2"
}

variable "primary_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "primary_subnet_cidr" {
  default = "10.0.1.0/24"
  type = string
}

variable "secondary_subnet_cidr" {
  default = "10.1.1.0/24"
    type = string
}

variable "instance_type" {
  default = "t2.micro"
type = string


}


