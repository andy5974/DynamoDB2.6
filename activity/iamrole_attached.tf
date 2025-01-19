# # Attach Policy 
# resource "aws_iam_role_policy_attachment" "tf-yl-dynamodb-policy-attach" {
#   role       = aws_iam_role.tf_dynamodb_role.name
#   policy_arn = aws_iam_policy.tf-dynamodb-policy.arn  
# }