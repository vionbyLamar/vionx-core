provider "azurerm" {
  features {}
}

output "message" {
  value = "Terraform is connected and running from GitHub Actions!"
}