variable "resource_group_name" {}
variable "default_location" {}

@ambient
@class default
resource "azurerm_resource_group" "default" {
  name = "${var.resource_group_name}"
  location = "${var.default_location}"
}

@ambient
resource "random_string" "instance" {
  length = 4
  upper = false
  special = false

  keepers = {
    name = "${var.resource_group_name}"
    location = "${var.default_location}"
  }
}
