provider "aws" {
  # access_key = "AKIA3WROU25H3TBLWYVT"
  # secret_key = "NiKSZcJ6gV9c0ZDnUFnWHsPYpsRQnCNs1eQb/G4Z"
  region     = var.region
}


terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-aws-kishan"
    key            = "bookstore/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}



