resource "aws_iam_user" "iam_user" {
  for_each = [ for user in local.users : user ]

  name = "each.value"
}