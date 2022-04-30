### Prerequisite Cloud Resources

The [cloudformation.yaml](cloudformation.yaml) file is an AWS CloudFormation template which creates the following: 

* **S3 Bucket** to serve as the target to which Terraform will write state files for your ephemeral (or permanent) environments in this demo. 

* **IAM Role** that Terraform will assume and which grants permission to create, read, update, and delete resources for this demonstration.