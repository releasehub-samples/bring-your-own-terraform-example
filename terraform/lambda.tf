# Lambda function that retrieves data from a 3rd-party API:
module "lambda_function" {
  function_name = substr("${local.unique_prefix_with_namespace}-terraform-demo",0, 64)
  source = "terraform-aws-modules/lambda/aws"
  description   = "Demo function created with Terraform via Release"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  source_path   = "./lambda"
  policy_path   = "/release/"
  role_path     = "/release/"
  role_name = "${local.unique_prefix_with_namespace}-lambda"
  cloudwatch_logs_retention_in_days = 30
}

# Terraform's "terraform_remote_state" data source allows one Terraform configuration
# to read the output of a remote state file. So, if you need to share state between
# different containers within the same environment, one way of accomplishing this is
# by writing outputs to state as shown below. To reference this value, you'll likely
# need to run your other Terraform as a job within the same environment / App Template
# so that the other job *also* has the same environment variables that tell it the 
# proper environment ID to know where you're storing your state:
output "lambda_function_arn" {
  value = module.lambda_function.lambda_function_arn
}

# We write our ephemeral Lambda's function name to AWS Parameter Store. This is
# just an example of an alternate way of sharing ephemeral Terraform outputs outside of
# your Release environment.
resource "aws_ssm_parameter" "lambda_function_arn" {
  name  = "/release/${local.unique_prefix}/lambda_function_name"
  type  = "String"
  value = module.lambda_function.lambda_function_arn
}