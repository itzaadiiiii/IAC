#In Terraform v1.12.0 and later, the import block can be used with the identity attribute. For example:

import {
    to = aws_security_group.example
    identity = {
        id = "sg-903004f8"
    }
}

resource "aws_security_group" "example" {
    ### Configuration omitted for brevity ###
}