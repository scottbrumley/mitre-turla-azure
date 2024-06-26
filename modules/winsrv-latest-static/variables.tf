variable "name" {
  type        = string
  description = "Base name of resource"
}

variable "location" {
  type        = string
  description = "Azure location for resource group"
}

variable "description" {
  type        = string
  description = "(Optional) Description tag of resource group"
  default     = ""
}

variable "environment" {
  type        = string
  description = "(Optional) Environment tag of resource group"
  default     = ""
}

variable "category" {
  type        = string
  description = "(Optional) Category of resource group, (similar to name, used for ansible automation)"
  default     = ""
}

variable "group_name" {
  type        = string
  description = "Resource group name to place VM"
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to place VM"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM"
}

variable "active_directory_domain_name" {
  type        = string
  description = "Domain name for active directory"
  default = ""
}

variable "active_directory_admin_username" {
  type        = string
  description = "Admin users username with permissions to bind machines to AD domain"
  default = ""
}

variable "active_directory_admin_password" {
  type        = string
  description = "Admin users password with permissions to bind machines to AD domain"
  default = ""
}

variable "source_image_sku" {
  type        = string
  description = "Sku for source image reference to use for VMs, override if necessary"
  default     = "2016-Datacenter"
}

variable "source_image_version" {
  type        = string
  description = "Version for source image reference to use for VMs, defaults to latest"
  default     = "latest"
}

variable "static_ip_list" {
  type        = list(string)
  description = "List of static IPs to assign to nics. NOTE: length of list will determine the number of NICs created. e.g., if you specify 3 IPs, then 3 NICs will be created."
}

variable "netbios_name" {
  type        = string
  description = "Hostname to use for system"
}

variable "azure_vm_size" {
  type        = string
  description = "Azure-specific string to determine VM resources (vCPU, memory, VM series). See Azure docs for list."
  default     = "Standard_D4s_v4"
}

variable "enable_ip_forwarding" {
  type        = bool
  description = "Whether to enable traffic forwarding within Azure"
  default     = true
}

variable "default_dns_servers" {
  type        = list(string)
  description = "DNS server to configure NIC. For Windows hosts on domain, should be set to domain controller. Setting to empty string will use vnet default."
  default     = null
}

variable "disk_storage_type" {
  type        = string
  description = "Type of disk to create, see Azure docs for valid list"
  default     = "StandardSSD_LRS"
}

variable "public_ip_address_id" {
  type        = string
  description = "If a public ip address is needed to be attached, pass in the id of the azurerm_public_ip resource. Defaults to null."
  default     = null
}

variable "disk_size" {
  type        = string
  description = "Size (in GiB) of OS disk"
  default     = null
}

locals {
  virtual_machine_name = var.netbios_name
  # truncate computer name to 15 chars per MS requirements
  computer_name           = substr(local.virtual_machine_name, 0, min(length(local.virtual_machine_name), 15))
  wait_for_domain_command = "while (!(Test-Connection -TargetName ${var.active_directory_domain_name} -Count 1 -Quiet) -and ($retryCount++ -le 360)) { Start-Sleep 10 }"
  auto_logon_data         = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
  first_logon_data        = file("${path.module}/files/FirstLogonCommands.xml")
  custom_data_params      = "Param($RemoteHostName = \"${local.virtual_machine_name}\", $ComputerName = \"${local.virtual_machine_name}\")"
  custom_data             = base64encode(join(" ", [local.custom_data_params, file("${path.module}/files/ConfigureRemotingForAnsible.ps1")]))
}
