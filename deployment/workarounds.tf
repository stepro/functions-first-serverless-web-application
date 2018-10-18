resource "null_resource" "azurerm_storage_static_website_frontend" {
  triggers = {
    storage_account_name = "${azurerm_storage_account.default.name}"
  }

  provisioner "local-exec" {
    command = "az storage blob service-properties update --account-name ${azurerm_storage_account.default.name} --static-website --index-document index.html"
  }
}

output "frontend" {
  value = "${data.external.azurerm_storage_account_default_primary_endpoints.result["web"]}"
}

resource "null_resource" "azurerm_function_app_cors_image_api" {
  triggers = {
    function_app_name = "${azurerm_function_app.image_api.name}"
  }

  provisioner "local-exec" {
    # TODO: drop trailing slash from primary_web_endpoint
    command = "az resource update -g ${azurerm_function_app.image_api.resource_group_name} --namespace Microsoft.Web --parent sites/${azurerm_function_app.image_api.name} --resource-type config -n web --api-version 2015-06-01 --set properties.cors.allowedOrigins=['${data.external.azurerm_storage_account_default_primary_endpoints.result["web"]}']"
  }
}

resource "null_resource" "azurerm_storage_cors_default" {
  triggers = {
    storage_account_name = "${azurerm_storage_account.default.name}"
  }

  provisioner "local-exec" {
    command = "az storage cors clear --account-name ${azurerm_storage_account.default.name} --services bfqt"
  }

  provisioner "local-exec" {
    command = "az storage cors add --account-name ${azurerm_storage_account.default.name} --origins ${data.external.azurerm_storage_account_default_primary_endpoints.result["web"]} --services b --methods GET PUT"
  }
}
