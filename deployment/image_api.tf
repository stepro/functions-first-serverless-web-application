resource "azurerm_function_app" "image_api" {
  app_settings {
    AZURE_STORAGE_CONNECTION_STRING = "${azurerm_storage_account.default.primary_connection_string}"
    FUNCTIONS_EXTENSION_VERSION     = "~1"
  }
}

# resource "azurerm_function_app_cors" "image_api" {
#   function_app_name = "{azurerm_function_app.image_api.name}"
#   allowed_origins = [
#     "${azurerm_storage_static_website.frontend.primary_endpoint}"
#   ]
# }

output "image_api" {
  value = "https://${azurerm_function_app.image_api.default_hostname}"
}