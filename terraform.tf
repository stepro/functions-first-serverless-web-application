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

resource "azurerm_storage_container" "images" {
  name                  = "images"
  resource_group_name   = "${azurerm_resource_group.gallery-app.name}"
  storage_account_name  = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_container" "thumbnails" {
  name                  = "thumbnails"
  resource_group_name   = "${azurerm_resource_group.gallery-app.name}"
  storage_account_name  = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_cosmosdb_account" "mymetadata" {
  name                = "mymetadata123"
  resource_group_name = "${azurerm_resource_group.gallery-app.name}"
  location            = "${azurerm_resource_group.gallery-app.location}"
  offer_type          = "Standard"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "${azurerm_resource_group.gallery-app.location}"
    failover_priority = 0
  }
}

# resource "azurerm_cosmosdb_database" "mymetadata_imagesdb" {
#   name                = "imagesdb"
#   cosmosdb_account_id = "${azurerm_cosmosdb_account.mymetadata.id}"
# }

# resource "azurerm_cosmosdb_collection" "imageMetadata" {
#   name                   = "images"
#   cosmosdb_account_id    = "${azurerm_cosmosdb_account.mymetadata.id}"
#   cosmosdb_database_name = "${azurerm_cosmosdb_database.mymetadata.name}"
#   throughput             = 400
# }

# resource "azurerm_cognitiveservices_account" "analyzer" {
#   name                = "analyzer"
#   resource_group_name = "${azurerm_resource_group.gallery-app.name}"
#   location            = "${azurerm_resource_group.gallery-app.location}"
#   kind                = "ComputerVision"
#   sku                 = "F0"
# }

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
    # ANALYZER_ENDPOINT                    = "${azurerm_cognitiveservices_account.analyzer.endpoint}"
    # ANALYZER_KEY                         = "${azurerm_cognitiveservices_account.analyzer.key1}"
    IMAGE_METADATA_DATABASE_ACCOUNT_CONNECTION_STRING = "AccountEndpoint=${azurerm_cosmosdb_account.mymetadata.endpoint};AccountKey=${azurerm_cosmosdb_account.mymetadata.primary_master_key};"
    IMAGES_ACCOUNT_CONNECTION_STRING     = "${azurerm_storage_account.mystorage.primary_connection_string}"
    IMAGES_NAME                          = "${azurerm_storage_container.images.name}"
    THUMBNAILS_ACCOUNT_CONNECTION_STRING = "${azurerm_storage_account.mystorage.primary_connection_string}"
    THUMBNAILS_NAME                      = "${azurerm_storage_container.thumbnails.name}"
  }
  # cors {
  #   allowed_origins = [
  #     "${substr(azurerm_storage_website.myfrontend.primary_endpoint, 0, length(azurerm_storage_website.myfrontend.primary_endpoint)-1)}"
  #   ]
  # }
}

resource "azurerm_azuread_application" "gallery-app" {
  name = "First Serverless Web Application"
  homepage = "https://${azurerm_function_app.myfunctions.default_hostname}"
  identifier_uris = [
    "https://${azurerm_function_app.myfunctions.default_hostname}"
  ]
  reply_urls = [
    "https://${azurerm_function_app.myfunctions.default_hostname}/.auth/login/aad/callback"
  ]
}

# resource "azurerm_function_app_authentication" "myfunctions_auth" {
#   function_app_id = ${azurerm_function_app.myfunctions.id}
#   authentication {
#     unauthenticated_client_action = "RedirectToLoginPage"
#     default_provider = "AzureActiveDirectory"
#     client_id = "${azurerm_azuread_application.gallery-app.application_id}"
#     issuer = "https://sts.windows.net/${????TENANT????}/"
#     allowed_audiences = [
#       "https://${azurerm_function_app.myfunctions.default_hostname}./auth/login/aad/callback""
#     ]
#     token_store = true
#     allowed_external_redirect_urls = [
#       "${azurerm_storage_website.myfrontend.primary_endpoint}"
#     ]
#   }
# }

# resource "azurerm_storage_account_cors_rule" "mystorage_cors" {
#   storage_account_name = "${azurerm_storage_account.mystorage.name}"
#   methods = ["OPTIONS", "PUT"]
#   origins = ["*"]
#   exposed_headers = ["*"]
#   allowed_headers = ["*"]
#   services = ["b"]
# }

# resource "azurerm_function_app_deployment" "myfunctions" {
#   function_app_id = "${azurerm_function_app.myfunctions.id}"
#   source_directory = "csharp"
# }

# resource "azurerm_storage_website" "myfrontend" {
#   storage_account_name = "${azurerm_storage_account.mystorage.name}"
#   index_document_name  = "index.html"
# }

resource "local_file" "frontend_settings" {
  filename = "www/dist/settings.js"

  content = <<EOF
window.settings = {}
window.settings.mybackend = {}
window.settings.mybackend.myfunctions = { defaultHostName: "${azurerm_function_app.myfunctions.default_hostname}" }
window.settings.mybackend.images = { primaryEndpoint: "${azurerm_storage_account.mystorage.primary_blob_endpoint}" }
EOF
}

# resource "azurerm_storage_website_content" "myfrontend" {
#   depends_on           = ["frontend_settings"]
#   storage_account_name = "${azurerm_storage_account.mystorage.name}"
#   source_directory     = "www/dist"
# }
