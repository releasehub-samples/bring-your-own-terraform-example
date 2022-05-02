# Release-provided variables are injected automatically by Release into each
# container and tell the containers about the context in which they exist.
# These are useful for tagging resources, giving unique names to resources, 
# logging, and similar use cases.
#
# Depending on which features you use with Release, there may be additional 
# variables that are injected into your container environments. 

variable "RELEASE_ACCOUNT_ID" {
  description = "Source repository branch that triggered this Release build"
  type        = string
}

variable "RELEASE_APP_NAME" {
  description = "Release Application name"
  type        = string
}

variable "RELEASE_ENV_ID" {
  description = "Release Environment ID"
  type        = string
}

variable "RELEASE_BRANCH_NAME" {
  description = "Source repository branch that triggered this Release build"
  type        = string
}

variable "RELEASE_COMMIT_SHORT" {
  description = "Short commit hash from the last commit that this Release environment was last created or updated from"
  type        = string
}

variable "RELEASE_COMMIT_SHA" {
  description = "Full commit SHA from the last commit that this Release environment was last created or updated from"
  type        = string
}

variable "AWS_DEFAULT_REGION" {
  description = "AWS region in which we will launch infrastructure."
  type        = string
}