resource "azurerm_function_app" "image_api" {
  app_settings {
    AZURE_STORAGE_CONNECTION_STRING = "${azurerm_storage_account.default.primary_connection_string}"
    COMP_VISION_KEY = "${data.external.azurerm_cognitive_services_account_analyzer_keys.result.key1}"
    COMP_VISION_URL = "${data.external.azurerm_cognitive_services_account_analyzer.result.endpoint}"
    FUNCTIONS_EXTENSION_VERSION     = "~1"
    IMAGE_METADATA_CONNECTION_STRING = "AccountEndpoint=${azurerm_cosmosdb_account.default.endpoint};AccountKey=${azurerm_cosmosdb_account.default.primary_master_key};"
  }
}

# resource "azurerm_app_service_authentication" "image_api" {
#   app_service_name = "${azurerm_function_app.image_api.name}"
#   azure_active_directory {
#     app_display_name = "First Serverless Web Application"
#   }
#   redirect_uris = [
#     "${azurerm_storage_static_website.frontend.primary_endpoint}"
#   ]
#   token_store = true
# }

# resource "azurerm_function_app_cors" "image_api" {
#   function_app_name = "${azurerm_function_app.image_api.name}"
#   allowed_origins = [
#     "${azurerm_storage_static_website.frontend.primary_endpoint}"
#   ]
# }

output "image_api" {
  value = "https://${azurerm_function_app.image_api.default_hostname}"
}