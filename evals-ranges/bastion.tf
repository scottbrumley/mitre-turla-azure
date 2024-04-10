resource "azurerm_public_ip" "bastion-pip" {
 name                = "bastion-pip"
 location            =  module.rgroup.location
 resource_group_name = module.rgroup.name
 allocation_method   = "Static"
 sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion-host" {
 name                = "bastion"
 location            = module.rgroup.location
 resource_group_name = module.rgroup.name
 ip_configuration {
  name                 = "configuration"
  subnet_id            = azurerm_subnet.carbon_srv.id
  public_ip_address_id = azurerm_public_ip.bastion-pip.id
 }
}
