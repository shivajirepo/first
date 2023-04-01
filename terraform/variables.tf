variable "ntier_cidr" {
    type = string
    default = "10.10.0.0/16"
}

variable "ntier_region" {
    type = string
    default = "ap-south-1"
}


variable "ntier_subnet_zones" {
    default = [ "ap-south-1a", "ap-south-1b", "ap-south-1c"]
  
}

variable "ntier_subnet_tags" {
    default = ["test1","test2", "test3"]
  
}

variable "dev_subnet_indexes" {
    type = list(number)
    default = [ 0 ]
}

