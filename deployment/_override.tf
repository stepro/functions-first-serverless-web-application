#
# GENERATED FILE - DO NOT EDIT
#

provider "azurerm" {}
variable "resource_group" {}
variable "default_location" {}

resource "azurerm_resource_group" "default" {
  name     = "${var.resource_group}"
  location = "${var.default_location}"
}

resource "random_string" "unique_suffix" {
  length  = 4
  upper   = false
  special = false

  keepers = {
    resource_group = "${var.resource_group}"
  }
}

resource "azurerm_storage_account" "default" {
  name                      = "default${random_string.unique_suffix.result}"
  resource_group_name       = "${azurerm_resource_group.default.name}"
  location                  = "${azurerm_resource_group.default.location}"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true

  // enable static website
}

resource "azurerm_storage_container" "images" {
  resource_group_name  = "${azurerm_storage_account.default.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.default.name}"
}

resource "azurerm_storage_container" "thumbnails" {
  resource_group_name  = "${azurerm_storage_account.default.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.default.name}"
}

resource "azurerm_app_service_plan" "default_consumption_plan" {
  name                = "default-consumption-plan"
  resource_group_name = "${azurerm_resource_group.default.name}"
  location            = "${azurerm_resource_group.default.location}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "image_api" {
  name                      = "image-api-${random_string.unique_suffix.result}"
  resource_group_name       = "${azurerm_resource_group.default.name}"
  location                  = "${azurerm_resource_group.default.location}"
  app_service_plan_id       = "${azurerm_app_service_plan.default_functions_plan.id}"
  storage_connection_string = "${azurerm_storage_account.default.primary_connection_string}"
}
