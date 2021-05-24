locals {
  common_tags = {
    environment      = "development"
    billing_code     = "342647563"
    project_code     = "8675309"
    network_lead     = "Mary Moe"
    application_lead = "Sally Sue"
  }

  workspace_key = "env:/${terraform.workspace}/${var.network_remote_state_key}"
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    key     = "${local.workspace_key}"
    bucket  = "${var.network_remote_state_bucket}"
    region  = "us-west-2"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
  }
}

data "aws_ami" "aws_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-20*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


data "aws_instances" "workers" {
  instance_state_names = ["running", "stopped"]
  
  instance_tags = {
    environment = "development"
  }
}