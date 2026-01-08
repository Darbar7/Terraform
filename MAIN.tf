
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "devops" {
  ami           = "ami-068c0051b15cdb816"
  instance_type = "t2.micro"
  key_name = "terraform"


  tags = {
    Name = "LAB"
  }
}