# If we apply the VPC you can fetch the AVAILABILITY ZONES using the below data source. This will help us to create subnets in different availability zones.
data "aws_availability_zones" "available" {
  state = "available"
}  