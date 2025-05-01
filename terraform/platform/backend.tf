terraform {
  backend "azurerm" {
    resource_group_name  = "vionx-core-state"
    storage_account_name = "vionxstatestorage"
    container_name       = "tfstate"
    key                  = "platform.terraform.tfstate"
  }
}