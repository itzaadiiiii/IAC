# Steps

Before running the script, make sure to replace "my-key" with your actual key name and "~/.ssh/my-key.pem"and create a key pair in AWS EC2 via aws cli, terraform or AWS console.

## command to create a key pair using AWS CLI

```bash
aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > ~/.ssh/my-key.pem
chmod 400 ~/.ssh/my-key.pem
```
