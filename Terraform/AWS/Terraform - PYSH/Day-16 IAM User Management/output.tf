data "aws_caller_identity" "current" {

}
output "caller_identity" {
  value = data.aws_caller_identity.current.id
}
