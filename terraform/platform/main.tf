# Root Terraform Config (terraform/platform/main.tf)

terraform {
  required_version = ">= 1.3.0"
  backend "azurerm" {
    resource_group_name  = "vionx-core-state"
    storage_account_name = "vionxstatestorage"
    container_name       = "tfstate"
    key                  = "platform.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "Azure/resource-group/azurerm"
  version = "2.0.0"

  location = "westeurope"
  name     = "vionx-core"
}

module "acr" {
  source  = "Azure/container-registry/azurerm"
  version = "2.0.0"

  name                = "vionxregistry"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Standard"
  admin_enabled       = false
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "7.4.0"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  prefix              = "vionx"

  kubernetes_version = "1.28.3"
  network_plugin     = "azure"
  identity_type      = "SystemAssigned"
  role_based_access_control_enabled = true
  sku_tier           = "Free"
}

module "storage" {
  source  = "Azure/storage-account/azurerm"
  version = "2.0.0"

  name                     = "vionxdatastore"
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "aks_kube_config" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "storage_account_endpoint" {
  value = module.storage.primary_blob_endpoint
}
