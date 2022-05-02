### Prerequisite Cloud Resources

The [cloudformation.yaml](cloudformation.yaml) file is an AWS CloudFormation template which creates the following: 

* **S3 Bucket** to serve as the target to which Terraform will write state files for your ephemeral (or permanent) environments in this demo. 

* **IAM Role** that Terraform will assume. While it has a minimal set of permissions, you will need to further refine this by adding permissions for the resources you'd like to manage. 