# how to deploy using terraform:

1. make necessary changes in all the files
2. run `terraform init` to initialize the Terraform and to create necessary files
3. run `terraform validate` to check if there is no errors in your terraform
4. run `terraform plan -out rke2_tf_plan` to save your plan in to the file
5. run `terraform apply "rke2_tf_plan"` to apply the plan and deploy the cluster on AWS
