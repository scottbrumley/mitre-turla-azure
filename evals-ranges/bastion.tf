resource "azurerm_virtual_network" "bastion-virtnet" {
 name                = "${var.name-prefix}-bastion-vnet"
 address_space       = ["192.168.1.0/24"]
 location            = module.rgroup.location
 resource_group_name = module.rgroup.name
}

resource "azurerm_subnet" "bastion-subnet" {
 name                 = "AzureBastionSubnet"
 resource_group_name  = module.rgroup.name
 virtual_network_name = azurerm_virtual_network.bastion-virtnet.name
 address_prefixes     = ["192.168.1.224/27"]
}

resource "azurerm_public_ip" "bastion-pip" {
 name                = "${var.name-prefix}-bastion-pip"
 location            =  module.rgroup.location
 resource_group_name = module.rgroup.name
 allocation_method   = "Static"
 sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion-host" {
 name                = "${var.name-prefix}-bastion"
 location            = module.rgroup.location
 resource_group_name = module.rgroup.name
 ip_configuration {
  name                 = "configuration"
  subnet_id            = azurerm_subnet.bastion-subnet.id
  public_ip_address_id = azurerm_public_ip.bastion-pip.id
 }
}
