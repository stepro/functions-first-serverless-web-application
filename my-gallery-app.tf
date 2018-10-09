provider azurerm {}

resource "azurerm_static_website" "myfrontend" {
  build {
    source = "www"
    commands = [
      "npm install",
      "npm run generate"
    ]
  }
  content = "www/dist"
  settings {
    auth_enabled = true
    apiBaseUrl = "https://${azurerm_function_app.myapi.defaultHostName}"
    blobBaseUrl = "${azurerm_storage_account.mystorage.primary_blob_endpoint}"
  }
  index = "index.html"
}

resource "azurerm_function_app" "myapi" {
  authentication {
    active_directory {
      app_display_name = "First Serverless Web Application"
    }
    token_store = true
    redirect_to = "${azure_static_website.myfrontend.primaryEndpoint}"
  }
  app_settings {
    ANALYZER_ENDPOINT = "${azurerm_cognitive_service.analyzer.endpoint}"
    ANALYZER_KEY = "${azurerm_cognitive_service.analyzer.key}"
    IMAGE_METADATA_DATABASE_ACCOUNT_CONNECTION_STRING = "${azurerm_cosmosdb_collection.image_metadata.connection_string}"
    IMAGES_ACCOUNT_CONNECTION_STRING = "${azurerm_storage_container.images.account.primary_connection_string}"
    THUMBNAILS_ACCOUNT_CONNECTION_STRING = "${azurerm_storage_container.thumbnails.account.primary_connection_string}"
  }
  function {
    source = "csharp/GetImages"
  }
  function {
    source = "csharp/GetImages"
  }
  function {
    source = "csharp/GetImages"
  }
}

resource "azurerm_storage_account" "mystorage" {
  cors {
    service = "blob"
    allowed_origins = ["${azurerm_static_website.myfrontend.primaryEndpoint}"]
    allowed_methods = ["GET", "PUT"]
  }
}

resource "azurerm_storage_container" "images" {
  storage_account_name = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_container" "thumbnails" {
  storage_account_name = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_cognitive_service" "analyzer" {
  kind = "ComputerVision"
}

resource "azurerm_cosmosdb_collection" "image_metadata" {
  name = "images"
  database {
    name = "imagesdb"
  }
}
