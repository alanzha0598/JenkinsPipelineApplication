#Remove State variables
variable "network_remote_state_key" {
  default = "networking.state"
}

variable "network_remote_state_bucket" {
  default = "ddt-networking-3456"
}

variable "aws_profile" {
  default = "sallysue"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}


#Web front end variables

variable "asg_instance_size" {
  default = "t2.micro"
}

variable "asg_max_size" {
  default = 4
}

variable "asg_min_size" {
  default = 1
}



variable "key_name" {
  default = "AWS_Alan_KP"
}

variable "ip_range" {
  default = "0.0.0.0/0"
}

variable "rds_username" {
  default     = "ddtuser"
  description = "User name"
}

variable "rds_password" {
  default     = "TerraformIsNumber1!"
  description = "password, provide through your ENV variables"
}

variable "projectcode" {
  default = "8675309"
}

 
