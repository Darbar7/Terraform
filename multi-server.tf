

provider "aws" {
  region = "us-east-1"
  alias = "NV"
}

provider "aws" {
  region = "ap-south-1"
  alias = "mumbai"
}

resource "aws_instance" "server-1" {
  ami           = "ami-068c0051b15cdb816"
  instance_type = "t2.micro"
  key_name = "terraform"
count = 1
provider = aws.NV
  tags = {
    Name = "test-1"
  }
}

resource "aws_instance" "server-2" {
  ami           = "ami-00ca570c1b6d79f36"
  instance_type = "t2.micro"
  key_name = "server-2"
count = 1
provider = aws.mumbai
  tags = {
    Name = "test-2"
  }
}