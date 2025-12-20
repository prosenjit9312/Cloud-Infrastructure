# NETWORK INTERFACE
# --------------------------------------
resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.value.vm_name}-nic"
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = each.value.tags
}

# --------------------------------------
# VIRTUAL MACHINE
# --------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = var.vms
  name                = each.value.vm_name
  resource_group_name = each.value.rg_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file(each.value.ssh_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  tags = each.value.tags
}
# newcode