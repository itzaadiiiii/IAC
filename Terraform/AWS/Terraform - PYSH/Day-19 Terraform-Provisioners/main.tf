data "aws_ami" "latest" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109469"] # Canonical
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]                                                         
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "web" {
    ami           = data.aws_ami.latest.id
    instance_type = "t2.micro"
    key_name      = "my-key" # Replace with your key name
    security_groups = [aws_security_group.allow_ssh.name]


        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = file("~/.ssh/my-key.pem") # Replace with your private key path
            host        = self.public_ip
        }

    tags = {
        Name = "Terraform-Example"
    }
}   

#Make sure you create the key pair in AWS and replace "my-key" and the private key path with your actual key name and path. This code will create an EC2 instance with the latest Ubuntu AMI, allow SSH access, and connect to it using the specified SSH key. and follow the instructions inside README.md for further steps.