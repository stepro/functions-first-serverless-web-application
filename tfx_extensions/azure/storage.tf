style "azurerm_storage_account" "" {
  resource_group_name      = "${azurerm_resource_group.default.name}"
  location                 = "${azurerm_resource_group.default.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

style "azurerm_storage_account" ".fast" {
  account_tier = "Premium"
}

style "azurerm_storage_account" ".global" {
  account_replication_type = "GRS"
}

style "azurerm_storage_account" ".secure" {
  enable_https_traffic_only = true
}

function "canonicalize" "value" {
  return = "${replace(lower(arg.value), "/[^a-z0-9]/", "")}"
}

function "azurerm_storage_account_name" "value" {
  lowered    = "${lower(arg.value)}"
  replaced   = "${replace(self.lowered, "/[^a-z0-9]/", "")}"
  max_length = "${24 - length(random_string.instance.result)}"
  truncated  = "${substr(self.replaced, 0, self.max_length)}"
  return     = "${self.truncated}{random_string.instance.result}"
}

resource "azurerm_storage_account" "mystorage" {
  name = "${storage_account_name("mystorage")}"
}

@ambient
@class default
resource "azurerm_storage_account" "default" {
  name = "${azurerm_storage_account_name(azurerm_resource_group.default.name)}"
}

style "azurerm_storage_container" "" {
  resource_group_name  = "${azurerm_storage_account.default.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.default.name}"
}

style "azurerm_storage_container" ".public" {
  container_access_type = "blob"
}

style "azurerm_storage_website" "" {
  resource_group_name  = "${azurerm_storage_account.default.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.default.name}"
}

reference "azurerm_storage_website" "azurerm_function_app" {
  source {
    settings {
      "${target_name}BaseUrl" = "https://${ref.default_host_name}"
    }
  }
  target {
    cors {
      allowed_origins = ["${source.primary_endpoint}"]
    }
  }
}

reference "azurerm_storage_website" "azurerm_storage_account" "blob_service" {
  source {
    settings {
      "${target_name}BlobBaseUrl" = "${target.primary_blob_endpoint}"
    }
  }
  target {
    cors {
      service = "blob"
      allowed_origins = ["${source.primary_endpoint}"]
      allowed_methods = ["OPTIONS", "GET", "PUT"]
      allowed_headers = ["*"]
      exposed_headers = ["*"]
    }
  }
}