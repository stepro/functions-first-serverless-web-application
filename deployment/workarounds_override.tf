#
# Workarounds for Terraform provider limitations
#

#
# frontend.tf
#

output "frontend" {
  value = "${data.external.azurerm_storage_account_default_primary_endpoints.result["web"]}"
}

#
# image_api.tf
#

resource "azurerm_function_app" "image_api" {
  app_settings {
    AZURE_STORAGE_CONNECTION_STRING  = "${azurerm_storage_account.default.primary_connection_string}"
    COMP_VISION_KEY                  = "${data.external.azurerm_cognitive_services_account_analyzer_keys.result["key1"]}"
    COMP_VISION_URL                  = "${data.external.azurerm_cognitive_services_account_analyzer.result["endpoint"]}vision/v1.0"
    FUNCTIONS_EXTENSION_VERSION      = "~1"
    IMAGE_METADATA_CONNECTION_STRING = "AccountEndpoint=${azurerm_cosmosdb_account.default.endpoint};AccountKey=${azurerm_cosmosdb_account.default.primary_master_key};"
  }
}
