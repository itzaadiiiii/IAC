resource "aws_instance" "firstinstance " {
    ami = ""
    instance_type = "t2.micro"
    key_name = "linuxxx.pem"
    tags = {
        Name = "${locals.CompanyName}-${locals.ProjectName}-${locals.Environment}-Instance"
    }
}

# variable.tf ----> locals.tf -----> main.tf     
#This how we can use both variables + locals for creating the resources



