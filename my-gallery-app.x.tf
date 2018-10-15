provider azurerm {}
include azurex {}

resource "azurerm_storage_website" "myfrontend" {
  @ref "azurerm_functionapp" "myapi"
  @ref "azurerm_storage_container" "images"
  @ref "azurerm_storage_container" "thumbnails"
  settings {
    auth_enabled = true
  }
  index = "index.html"
}

resource "azurerm_storage_website_files" "myfrontend" {
  @build {
    source = "www"
    commands = [
      "npm install",
      "npm run generate"
    ]
    package = "www/dist"
  }
}

resource "azurerm_function_app" "myapi" {
  package {
    source = "csharp"
  }
  @apply auth_aad {
    app_display_name = "First Serverless Web Application"
    redirect_to = "${azure_storage_website.myfrontend.primary_endpoint}"
  }
  @ref "azurerm_cognitive_service" "analyzer" {}
  @ref "azurerm_cosmosdb_collection" "image_metadata" {}
  @ref "azurerm_storage_container" "images" {}
  @ref "azurerm_storage_container" "thumbnails" {}
}

@feature public
resource "azurerm_storage_container" "images" {}

@feature public
resource "azurerm_storage_container" "thumbnails" {}

resource "azurerm_cognitive_service" "analyzer" {
  kind = "ComputerVision"
}

resource "azurerm_cosmosdb_collection" "image_metadata" {
  name = "images"
}

resource "azurerm_storage_container" "mycontainer" {
  @resource "azurerm_storage_account" "mystorage" {
    name = "mystorage123"
  }
  storage_account_name = "${@resource.azurerm_storage_account.mystorage.name}"
}

macro "azurerm_storage_account" "fast" {
  account_tier = "Premium"
}

resource "azurerm_storage_account" "default" {
  name = "default123"
  @apply "fast"
}

resource "azurerm_storage_container" "mycontainer" {
  storage_account_name = "${azurerm_storage_account.default.name}"
}

type "mongo" "azurerm_cosmosdb_account" {
  ip_range_filter = "${arg.allow}"
  kind = "MongoDB"
}

resource "mongo" "mydata" {
  name                = "mydata"
  resource_group_name = "myrg"
  location            = "westus"
  allow               = "1.2.3.4"
}

resource "azurerm_cosmosdb_account" "mydata" {
  kind                = "MongoDB"
  name                = "mydata"
  resource_group_name = "myrg"
  location            = "westus"
  ip_range_filter     = [
    "${arg.allow}"
  ]
}

rule "azurerm_storage_account" "" {
  account_tier = "Standard"
}

resource "azurerm_storage_account" "mystorage" {
  name = ""
}
