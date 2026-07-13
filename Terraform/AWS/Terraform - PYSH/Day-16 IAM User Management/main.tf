resource "aws_iam_user" "iam_user" {
for_each = [ for user in local.users : "${user.name} ${user.last_name}"]
    name = "each.value"
}
