#
# GENERATED FILE - DO NOT EDIT
#

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
  name                      = "${substr(replace(lower(azurerm_resource_group.default.name), "/[^a-z0-9]/", ""), 0, min(length(replace(lower(azurerm_resource_group.default.name), "/[^a-z0-9]/", "")), 20))}${random_string.unique_suffix.result}"
  resource_group_name       = "${azurerm_resource_group.default.name}"
  location                  = "${azurerm_resource_group.default.location}"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

data "external" "azurerm_storage_account_default_primary_endpoints" {
  program = ["az", "storage", "account", "show",
    "--ids",
    "${azurerm_storage_account.default.id}",
    "--query",
    "primaryEndpoints",
    "-o",
    "json",
  ]
}

resource "azurerm_storage_container" "images" {
  resource_group_name  = "${azurerm_storage_account.default.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.default.name}"
}

# resource "azurerm_storage_container" "thumbnails" {
#   resource_group_name  = "${azurerm_storage_account.default.resource_group_name}"
#   storage_account_name = "${azurerm_storage_account.default.name}"
# }

resource "azurerm_app_service_plan" "default_consumption_plan" {
  name                = "${substr(replace(lower(azurerm_resource_group.default.name), "/[^A-Za-z0-9-_]/", ""), 0, min(length(replace(lower(azurerm_resource_group.default.name), "/[^A-Za-z0-9-_]/", "")), 48))}-consumption"
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
  app_service_plan_id       = "${azurerm_app_service_plan.default_consumption_plan.id}"
  storage_connection_string = "${azurerm_storage_account.default.primary_connection_string}"
}
