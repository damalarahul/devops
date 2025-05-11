resource "azurerm_resource_group" "devopsdev-rg" {
 name = "devopsdev-rg"
 location = "east-us"
}

resource "azurerm_virtual_network" "devopsdev-vnet" {
 name = "devopsdev-vnet"
 address_space = ["10.50.0.0/16"]
 location = azurerm_resource_group.devopsdev-rg.location
 resource_group_name = azurerm_resource_group.devopsdev-rg.name
}

resource "azurerm_subnet" "devopsdev-sn" {
 name = "internal"
 resource_group_name = azurerm_resource_group.devopsdev-rg.name
 virtual_network_name = azurerm_virtual_network.devopsdev-vnet.name
 address_prefixes = ["10.50.0.0/24"]
}

resource "azurerm_network_interface" "webvm-nic" {
 name = "webvm-nic"
 location = azurerm_resource_group.devopsdev-rg.location
 resource_group_name = azurerm_resource_group.devopsdev-rg.name

 ip_configuration {
 name = "internal"
 subnet_id = azurerm_subnet.devopsdev-sn.id
 private_ip_address_allocation = "Dynamic"
 }
}

resource "azurerm_windows_virtual_machine" "devopsdevvm1" {
 name = "devopsdevvm1"
 resource_group_name = azurerm_resource_group.devopsdev-rg.name
 location = azurerm_resource_group.devopsdev-rg.location
 size = "Standard_F2"
 admin_username = "adminuser"
 admin_password = "P@$$w0rd1234!"
 network_interface_ids = [
 azurerm_network_interface.webvm-nic.id,
 ]

 os_disk {
 caching = "ReadWrite"
 storage_account_type = "Standard_LRS"
 }

 source_image_reference {
 publisher = "MicrosoftWindowsServer"
 offer = "WindowsServer"
 sku = "2016-Datacenter"
 version = "latest"
 }
}
