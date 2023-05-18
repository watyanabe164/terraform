# main.tf

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "pro-nabehiro-001"
  location = "japaneast"
}
