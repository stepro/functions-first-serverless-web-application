provider "azure" {}

resource "azure_storage_website" "myfrontend" {
  requires = {
    resource = "GetImages"
  }
  requires = {
    resource = "GetUploadUrl"
  }
  requires = {
    resource = "images"
    storage_container = {
      methods = ["GET", "PUT"]
    }
  }
  content = "www/dist"
  settings = {
    name = "authEnabled"
    value = "true"
  }
  index = "index.html"
}

resource "azure_function_app" "myfunctions" {
  authentication = {
    active_directory = {
      app_display_name = "First Serverless Web Application"
    }
    token_store = true
    redirect_to = "${azure_storage_website.myfrontend.id}"
  }
}

resource "azure_function" "GetImages" {
  app = "${azure_function_app.myfunctions}"
  requires = {
    resource = "imageMetadata"
    include_sensitive_properties = true
  }
  source = "csharp/GetImages"
}

resource "azure_function" "GetUploadUrl" {
  app = "${azure_function_app.myfunctions}"
  requires = {
    resource = "images"
    include_sensitive_properties = true
  }
  source = "csharp/GetUploadUrl"
}

resource "azure_function" "ResizeImage" {
  app = "${azure_function_app.myfunctions}"
  requires = {
    resource = "images"
    include_sensitive_properties = true
  }
  requires = {
    resource = "thumbnails"
    include_sensitive_properties = true
  }
  requires = {
    resource = "analyzer"
    include_sensitive_properties = true
  }
  requires = {
    resource = "imageMetadata"
    include_sensitive_properties = true
  }
  source = "csharp/ResizeImage"
}

resource "azure_storage_container" "images" {
  public_access_level = "blob"
}

resource "azure_storage_container" "thumbnails" {
  public_access_level = "blob"
}

resource "azure_cognitive_service" "analyzer" {
  kind = "ComputerVision"
}

resource "azure_cosmosdb_collection" "image_metadata" {
  name = "images"
  database = {
    name = "imagesdb"
  }
  throughput = 400
}
