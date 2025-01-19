terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key = "wx-dynamodb-with-permissions.tfstate"
    region = "ap-southeast-1"
  }
}