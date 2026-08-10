# Lets fetch the latest Ubuntu AMI from AWS using the aws_ami data source. This will ensure that we are always using the most up-to-date version of Ubuntu for our EC2 instance.
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

# Create a security group to allow SSH access to the EC2 instance. This security group will allow inbound traffic on port 22 (SSH) from any IP address (
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


#Create an EC2 instance using the latest Ubuntu AMI and allow SSH access using the specified key pair. The instance will be tagged with the name "Terraform-Example".
resource "aws_instance" "web" {
    ami           = data.aws_ami.latest.id
    instance_type = var.instance_type
    key_name      = var.key_name
    security_groups = [
        aws_security_group.allow_ssh.name
        ]


    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/my-key.pem") # Replace with your private key path
        host        = self.public_ip
    }

    tags = {
        Name = "Terraform-Example"
    }

    provisioner "local-exec" {
        command = "echo 'Local-exec provisioner: Instance created with Instance ID: ${self.id}, and Public IP: ${self.public_ip}'"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -y",
            "echo Hello from remote-exec provisioner | sudo tee /tmp/remote-exec.txt"
        ]
    }
# The file provisioner is used to copy files from the local machine to the remote EC2 instance. In this case, we are copying a script named welcome.sh from the local module path to the /tmp directory on the EC2 instance. You can modify the source and destination paths as needed.
    provisioner "file" {
        source      = "${path.module}/Day-19 Terraform-Provisioners/welcome.sh" # Replace with your local file path
        destination = "/tmp/welcome.sh"   #You can change the destination path as needed
    }

# The remote-exec provisioner is used to execute commands on the remote EC2 instance. In this case, we are making the welcome.sh script executable and then running it. You can modify the commands as needed.
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/welcome.sh",
            "/tmp/welcome.sh"
        ]
    }
}   


#Make sure you create the key pair in AWS and replace "my-key" and the private key path with your actual key name and path. This code will create an EC2 instance with the latest Ubuntu AMI, allow SSH access, and connect to it using the specified SSH key. and follow the instructions inside README.md for further steps.