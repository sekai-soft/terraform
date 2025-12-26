# terraform

## How to import an existing resource with TFC
1. Move all sensitive variables from TFC to `prod.auto.tfvars`
3. Declare the resource in Terraform code
4. Do `terraform import` with `-var-file=prod.auto.tfvars`
5. Try `terraform plan` and potentially fix resource declaration in Terraform
6. Move back sensitive variables to TFC
7. Do a plan and apply again in TFC

Notice: you may not be able to import multiple resources at once if there is dependency among them

[HashiCorp official reference](https://learn.hashicorp.com/tutorials/terraform/state-import)
