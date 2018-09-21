provider "azurerm" {}

resource "azurerm_resource_group" "gallery-app" {
  name     = "gallery-app"
  location = "West US"
}

resource "azurerm_storage_account" "mystorage" {
  name                      = "galleryapp123"
  resource_group_name       = "${azurerm_resource_group.gallery-app.name}"
  location                  = "${azurerm_resource_group.gallery-app.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
}

# Type missing; might look something like:
# resource "azurerm_storage_account_cors_rule" "cors" {
#   storage_account_name = "${azurerm_storage_account.mystorage.name}"
#   methods = ["OPTIONS", "PUT"]
#   origins = ["*"]
#   exposed_headers = ["*"]
#   allowed_headers = ["*"]
#   services = ["b"]
# }

# Type missing; might look something like:
# resource "azurerm_storage_website" "myfrontend" {
#   storage_account_name = "${azurerm_storage_account.mystorage.name}"
#   index_document_name  = "index.html"
# }

resource "local_file" "frontend_settings" {
  filename = "www/dist/settings.js"
  content  = <<EOF
window.settings = {}
window.settings.mybackend = {}
window.settings.mybackend.myfunctions = { defaultHostName: "${azurerm_function_app.myfunctions.default_hostname}" }
window.settings.mybackend.images = { primaryEndpoint: "${azurerm_storage_account.mystorage.primary_blob_endpoint}"}
EOF
}

# Type missing; might look something like:
# resource "azurerm_storage_website_content" "myfrontend" {
#   storage_account_name = "${azurerm_storage_account.mystorage.name}"
#   source_directory     = "www/dist"
#   additional_files
# }

resource "azurerm_storage_container" "images" {
  name                  = "images"
  resource_group_name   = "${azurerm_resource_group.gallery-app.name}"
  storage_account_name  = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_app_service_plan" "myfunctions-plan" {
  name                = "myfunctions-plan"
  resource_group_name = "${azurerm_resource_group.gallery-app.name}"
  location            = "${azurerm_resource_group.gallery-app.location}"
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "myfunctions" {
  name                      = "myfunctions123"
  resource_group_name       = "${azurerm_resource_group.gallery-app.name}"
  location                  = "${azurerm_resource_group.gallery-app.location}"
  app_service_plan_id       = "${azurerm_app_service_plan.myfunctions-plan.id}"
  storage_connection_string = "${azurerm_storage_account.mystorage.primary_connection_string}"
  app_settings {
    IMAGES_ACCOUNT_CONNECTION_STRING = "${azurerm_storage_account.mystorage.primary_connection_string}"
    IMAGES_NAME                      = "${azurerm_storage_container.images.name}"
  }
  # Properties missing; might look something like:
  # cors {
  #     allowed_origins = [
  #         "${substr(azurerm_storage_website.myfrontend.primary_endpoint, 0, length(azurerm_storage_website.myfrontend.primary_endpoint)-1)}"
  #     ]
  # }
}

# Type missing; might look something like:
# resource "azurerm_function_app_deployment" "myfunctions" {
#     function_app_id = "${azurerm_function_app.myfunctions.id}"
#     source_directory = "csharp"
# }
