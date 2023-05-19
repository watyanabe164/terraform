# main.tf

provider "azurerm" {
  features {}
}

# Terraformの設定
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

# Azureプロバイダの設定
provider "azurerm" {
  features {}
}

# リソースグループの作成
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "Japan East"
}

# 仮想ネットワークの作成
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# サブネットの作成
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# 仮想マシン1の作成
resource "azurerm_virtual_machine" "example1" {
  name                  = "example-vm1"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example1.id]

  vm_size              = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "example-vm1"
    admin_username = "adminuser"
    admin_password = "password1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo service nginx start"
    ]
  }
}

# 仮想マシン2の作成（仮想マシン1と同様の設定）
resource "azurerm_virtual_machine" "example2" {
  name                  = "example-vm2
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example2.id]

  vm_size              = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "example-vm2"
    admin_username = "adminuser"
    admin_password = "password1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo service nginx start"
    ]
  }
}

# Application Gatewayの作成
resource "azurerm_application_gateway" "example" {
  name                = "example-app-gateway"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard_Medium"
  gateway_ip_configuration {
    name      = "example-gateway-ip"
    subnet_id = azurerm_subnet.example.id
  }
  frontend_port {
    name = "example-frontend-port"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "example-frontend-ip"
    public_ip_address_id = azurerm_public_ip.example.id
  }
  backend_address_pool {
    name = "example-backend-pool"
  }
  backend_http_settings {
    name                  = "example-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "example-http-listener"
    frontend_ip_configuration_name = "example-frontend-ip"
    frontend_port_name             = "example-frontend-port"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "example-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = azurerm_application_gateway.example.http_listener[0].name
    backend_address_pool_name  = azurerm_application_gateway.example.backend_address_pool[0].name
    backend_http_settings_name = azurerm_application_gateway.example.backend_http_settings[0].name
  }
}

# パブリックIPアドレスの作成
resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}

# ネットワークインターフェース1の作成
resource "azurerm_network_interface" "example1" {
  name                = "example-nic1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  ip_configuration {
    name                          = "example-ipconfig1"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# ネットワークインターフェース2の作成（ネットワークインターフェース1と同様の設定）
resource "azurerm_network_interface" "example2" {
  name                = "example-nic2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  ip_configuration {
    name                          = "example-ipconfig2"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
