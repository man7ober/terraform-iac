## HashiCorp Terraform

- Tool for creating and configurating infrastructure
- Current State (AWS) compares to Desired State (TerraForm)

## Commands :

**terraform init**

- initialize terraform repository

**terraform refresh**

- query infrastructure provider to get the current state

**terraform plan**

- create an execution plan

**terraform apply**

- execute the plan

**terraform destroy**

- destroy the resources / infrastructure

**terraform state**

- used to check the Terraform state

## Flags :

- auto-approve
- target
- migrate-state

## Best Practices :

- Manipulate state only through terraform commands
- Always set up a shared remote state
- Use state locking
- Back up your state files
- Use 1 state per environment
- Host terraform scripts in git repository
- CI for terraform code
- Apply terraform only through CD pipeline
