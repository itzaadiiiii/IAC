resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.company}-${local.project}-state"
}


resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = "t2.micro"

  tags = {
    Name = "${var.company}-${local.project}-web_server"
    Env  = var.env
  }
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.company}-${local.project}-vpc"
    Env  = var.env
  }
}



