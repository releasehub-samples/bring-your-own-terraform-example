terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.7.2"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  region = var.AWS_DEFAULT_REGION

  # Release automatically injects variables like RELEASE_<SOME_VALUE>, which we map to
  # their equivalent TF_VAR_RELEASE_<SOME_VALUE> in the ./release/environment_variables.yaml.
  # Below, we leverage these variables to tag every Terraform resource we create with 
  # relevent info about our environment. You could just as easily adapt this approach
  # to annotate any number of things, such as logging, database entries, 
  # otherwise  external to your containers, such as a logging solution
  default_tags {
	  tags = {
      purpose   = "Demo - Terraform with Release"
      terraform_apply_time = time_static.timestamp.rfc3339
      release_application  = var.RELEASE_APP_NAME
      release_environment  = var.RELEASE_ENV_ID
      release_branch       = var.RELEASE_BRANCH_NAME
      release_commit       = var.RELEASE_COMMIT_SHORT
      release_account      = var.RELEASE_ACCOUNT_ID
    }
  }
}


locals {
  # Because we could potentially have more than one environment created from the 
  # same code branch, we need to ensure that *if* we are hard-coding the names of
  # resources (or the Terraform modules we're using do this for us in some deterministic
  # fashion) that we add a unique identifier that maps to the specific environment 
  # it's running in. Otherwise, our terraform apply command would fail because of
  # a name collision.
  #
  # One way to solve this is to let AWS choose a random name for you (whether they
  # do this depends on the API and the Terraform module they use).
  #
  # A second way (that we prefer) is to use a combination of the Release App Name
  # and Environment ID as part of the resource name. Not only does this help you
  # avoid name collisions, but it also makes it easy to quickly identify where
  # something came from. (Note that we also add this information to default tags 
  # above).
  #
  # This approach is valuable beyond resource names, too. For example, you can use
  # this string for things like annotations / labels / etc. in your preferred
  # logging and metrics solution, as columns or attributes in a database, or as 
  # part of a custom reporting solution.
  unique_resource_namespace = "${var.RELEASE_APP_NAME}-${var.RELEASE_ENV_ID}"
}

# Lambda function that retrieves data from a 3rd-party API:
module "lambda_function" {
  function_name = substr("${local.unique_resource_namespace}-terraform-demo",0, 64)
  source = "terraform-aws-modules/lambda/aws"
  description   = "Demo function created with Terraform via Release"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  source_path   = "./lambda"
}

# Used to create a timestamp used in AWS resource tags but which does *not* 
# change from the last 'terraform apply' unless other resources have changed
# in the template (to avoid unnecessary Terraform updates.
resource "time_static" "timestamp" {}


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

# Below, we write our ephemeral Lambda's function name to AWS Parameter Store. This is
# just an example of an alternate way of sharing ephemeral Terraform outputs outside of
# your Release environment.
resource "aws_ssm_parameter" "lambda_function_arn" {
  name  = "/${local.unique_resource_namespace}/lambda_function_name"
  type  = "String"
  value = module.lambda_function.lambda_function_arn
}
