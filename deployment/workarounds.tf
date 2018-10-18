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

resource "null_resource" "azurerm_cosmosdb_database_imagesdb" {
  triggers = {
    cosmosdb_account_name = "${azurerm_cosmosdb_account.default.name}"
  }

  provisioner "local-exec" {
    command = "az cosmosdb database create -n ${azurerm_cosmosdb_account.default.name} -g ${azurerm_cosmosdb_account.default.resource_group_name} --db-name imagesdb"
  }
}

resource "null_resource" "azurerm_cosmosdb_collection_images" {
  triggers = {
    cosmosdb_account_name = "${azurerm_cosmosdb_account.default.name}"
  }

  provisioner "local-exec" {
    command = "az cosmosdb collection create -n ${azurerm_cosmosdb_account.default.name} -g ${azurerm_cosmosdb_account.default.resource_group_name} --db-name imagesdb --collection-name images --throughput 400"
  }
}

resource "null_resource" "azurerm_cognitive_services_account_analyzer" {
  provisioner "local-exec" {
    command = "az cognitiveservices account create -n analyzer -g ${azurerm_resource_group.default.name} -l ${azurerm_resource_group.default.location} --kind ComputerVision --sku F0 --yes"
  }
}

data "external" "azurerm_cognitive_services_account_analyzer" {
  program = ["az", "cognitiveservices", "account", "show",
    "-n",
    "analyzer${substr(null_resource.azurerm_cognitive_services_account_analyzer.id, 0, 0)}",
    "-g",
    "${azurerm_resource_group.default.name}",
    "--query",
    "{endpoint: endpoint}",
    "-o",
    "json",
  ]
}

data "external" "azurerm_cognitive_services_account_analyzer_keys" {
  program = ["az", "cognitiveservices", "account", "keys", "list",
    "-n",
    "analyzer${substr(null_resource.azurerm_cognitive_services_account_analyzer.id, 0, 0)}",
    "-g",
    "${azurerm_resource_group.default.name}",
    "-o",
    "json",
  ]
}

# resource "azurerm_azuread_application" "image_api" {
#   name = "First Serverless Web Application"
#   homepage = "https://${azurerm_function_app.image_api.default_hostname}"
#   identifier_uris = "https://${azurerm_function_app.image_api.default_hostname}"
#   reply_urls = [
#     "${data.external.azurerm_storage_account_default_primary_endpoints.result["web"]}.auth/login/aad/callback"
#   ]
# }

# resource "null_resource" "azurerm_app_service_authentication_image_api" {
#   provisioner "local-exec" {
#     command = "az resource invoke-action -g"
#   }
# }