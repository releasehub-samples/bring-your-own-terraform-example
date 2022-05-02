terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.9.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.0.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

provider "random" {
  # Configuration options
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
      release_managed      = "true"
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
  unique_prefix_with_namespace = "release-${var.RELEASE_APP_NAME}-${var.RELEASE_ENV_ID}"
  unique_prefix                = "${var.RELEASE_APP_NAME}-${var.RELEASE_ENV_ID}"
  
}