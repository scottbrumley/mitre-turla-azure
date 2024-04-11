resource "azurerm_subnet" "bastion-subnet" {
 name                 = "AzureBastionSubnet"
 resource_group_name  = module.rgroup.name
 virtual_network_name = azurerm_virtual_network.vnet3.name
 address_prefixes     = [var.vnet3-sub2-range]
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
