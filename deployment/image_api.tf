provider "azurerm" {}

resource "azurerm_function_app" "image_api" {
    app_settings {
        AZURE_STORAGE_CONNECTION_STRING = "${azurerm_storage_account.default.primary_connection_string}"
        FUNCTIONS_EXTENSION_VERSION = "~1"
    }
}

resource "null_resource" "image_api_cors_rules" {
    provisioner "local-exec" {
        # TODO: drop trailing slash from primary_web_endpoint
        command = <<EOF
            az resource update -g ${azurerm_function_app.image_api.resource_group_name} \
                --namespace Microsoft.Web \
                --parent "sites/${azurerm_function_app.image_api.name}" \
                --resource-type config \
                -n web \
                --api-version 2015-06-01 \
                --set properties.cors.allowedOrigins="['${azurerm_storage_account.default.primary_web_endpoint}']"
        EOF
    }
}