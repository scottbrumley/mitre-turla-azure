resource "azurerm_subnet" "AzureBastionSubnet" {
 name                 = "AzureBastionSubnet"
 resource_group_name  = module.rgroup.name
 virtual_network_name = azurerm_virtual_network.vnet3.name
 address_prefixes     = ["91.52.64.0/26"]
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
  subnet_id            = azurerm_subnet.AzureBastionSubnet.id
  public_ip_address_id = azurerm_public_ip.bastion-pip.id
 }
}
