provider azurerm {}

resource "azurerm_storage_website" "myfrontend" {
  build {
    source = "www"
    commands = [
      "npm install",
      "npm run generate"
    ]
  }
  content = "www/dist"
  @ref "azurerm_functionapp" "myapi"
  @ref "azurerm_storage_account" "default" "blob_endpoint"
  settings {
    auth_enabled = true
  }
  index = "index.html"
}

resource "azurerm_function_app" "myapi" {
  package {
    source = "csharp"
  }
  $auth {
    app_display_name = "First Serverless Web Application"
    redirect_to = "${azure_storage_website.myfrontend.primary_endpoint}"
  }
  @ref "azurerm_cognitive_service" "analyzer" {}
  @ref "azurerm_cosmosdb_collection" "image_metadata" {}
  @ref "azurerm_storage_container" "images" {}
  @ref "azurerm_storage_container" "thumbnails" {}
}

@class public
resource "azurerm_storage_container" "images" {}

@class public
resource "azurerm_storage_container" "thumbnails" {}

resource "azurerm_cognitive_service" "analyzer" {
  kind = "ComputerVision"
}

resource "azurerm_cosmosdb_collection" "image_metadata" {
  name = "images"
}
