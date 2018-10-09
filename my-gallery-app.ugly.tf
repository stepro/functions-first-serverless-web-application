provider azurerm {}

# MUST provide resource group name, can't generate one
variable "name" {}

# MUST define a resource group for the resources
resource "azurerm_resource_group" "default" {
  # MUST specify the actual name when I really don't care
  name = "${var.name}"
}

resource "azurerm_static_website" "myfrontend" {
  # MUST pass hosting storage account name when I don't care about it
  # I can't reference a storage account object, only using its name
  storage_account_name = "${azurerm_storage_account.mystorage.name}"
  # CANNOT do this with Terraform or any other deployment platforms with the
  # exception of Docker Compose and maybe Pulumi. Specifically, combining the
  # definition of where source code is, how to build it, and how to deploy.
  build {
    source = "www"
    commands = [
      "npm install",
      "npm run generate"
    ]
  }
  # CANNOT realistically point to a location on disk containing the app code
  # to be deployed - generally expect to point at some pre-baked package.
  content = "www/dist"
  settings {
    auth_enabled = true
    # The syntax for referencing outputs from elsewhere is kind of verbose
    apiBaseUrl = "https://${azurerm_function_app.myapi.defaultHostName}"
    # How to deal with primary vs. secondary as references?
    blobBaseUrl = "${azurerm_storage_account.mystorage.primary_blob_endpoint}"
  }
  index = "index.html"
}

# I'm forced to think of my functions as a group of APIs in a
# function app - what if I don't want to think of them that way?
resource "azurerm_function_app" "myapi" {
  # MUST pass resource group to EVERY top-level resource
  resource_group_name = "${azurerm_resource_group.default.name}"
  authentication {
    active_directory {
      app_display_name = "First Serverless Web Application"
    }
    token_store = true
    redirect_to = "${azure_static_website.myfrontend.primaryEndpoint}"
  }
  # I can't define what each function requires, only what the entire app requires
  app_settings {
    # I can't say something simple like "A requires B"
    ANALYZER_ENDPOINT = "${azurerm_cognitive_service.analyzer.endpoint}"
    ANALYZER_KEY = "${azurerm_cognitive_service.analyzer.key}"
    IMAGE_METADATA_DATABASE_ACCOUNT_CONNECTION_STRING = "${azurerm_cosmosdb_collection.image_metadata.connection_string}"
    # I actually can't do this, because the account properties aren't
    # available on the images storage container, only on the actual
    # account, but I want to think of my connection string to images
    # as independent to the connection string for thumbnails...
    IMAGES_ACCOUNT_CONNECTION_STRING = "${azurerm_storage_container.images.account.primary_connection_string}"
    THUMBNAILS_ACCOUNT_CONNECTION_STRING = "${azurerm_storage_container.thumbnails.account.primary_connection_string}"
  }
  # Can't easily define functions like this - need to package
  # them all up into a single ZIP deployable package first
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
  # MUST pass resource group to EVERY top-level resource
  resource_group_name = "${azurerm_resource_group.default.name}"
  # I can't simply state intent, i.e. "I allow myfrontend to talk to me"
  cors {
    service = "blob"
    allowed_origins = ["${azurerm_static_website.myfrontend.primaryEndpoint}"]
    allowed_methods = ["GET", "PUT"]
  }
}

resource "azurerm_storage_container" "images" {
  # I can't reference a storage account object, only by name, which
  # means I then can't extract the images account connection string
  storage_account_name = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_container" "thumbnails" {
  # I can't reference a storage account object, only by name, which
  # means I then can't extract the thumbnails account connection string
  storage_account_name = "${azurerm_storage_account.mystorage.name}"
  container_access_type = "blob"
}

resource "azurerm_cognitive_service" "analyzer" {
  # MUST pass resource group to EVERY top-level resource
  resource_group_name = "${azurerm_resource_group.default.name}"
  # The portal exposes "computer vision" at the top level, which is
  # more intuitive; Terraform exposes things at an API level that is
  # more confusing
  kind = "ComputerVision"
}

resource "azurerm_cosmosdb_collection" "image_metadata" {
  # MUST pass resource group to EVERY top-level resource
  resource_group_name = "${azurerm_resource_group.default.name}"
  name = "images"
  # I can't inline define the database for the collection (and
  # subsequently the account for the database) - these must be
  # created independently at the top-level but that just gets
  # in the way of focusing on what I care about (image_metadata).
  database {
    name = "imagesdb"
  }
}
