# terraform {
#   backend "azurerm" {
#     resource_group_name = "Devops-RG"
#     storage_account_name = "devopsstatefilessa"
#     container_name = "tf-state"
#     key = "dev.terraform.tfstate"
#   }
# }
terraform {
 backend "local" {
 path = "C:/Users/Rahul/OneDrive/documents/devops/terraform/dev.terraform.tfstate"
 }
}