##################################################################################
# BACKENDS
##################################################################################

terraform {
  backend "s3" {
    profile = "sallysue"
    bucket = "ddt-application-3456"
    dynamodb_table = "ddt-tfstatelock"
    key = "application.state"
    region = "us-west-2"
  }
}

