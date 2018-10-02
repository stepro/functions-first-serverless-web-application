provider "google" {
  project = "my-gce-project-id"
  region  = "us-central1"
}

resource "google_storage_bucket" "images" {
  name     = "images"
  location = "US"

  cors {
    origin          = ["*"]
    method          = ["PUT"]
    response_header = ["*"]
  }
}

resource "google_storage_bucket" "thumbnails" {
  name     = "thumbnails"
  location = "US"

  cors {
    origin          = ["*"]
    method          = ["PUT"]
    response_header = ["*"]
  }
}

resource "google_sql_database_instance" "image_metadata" {
  name = "image-metadata"

  settings {
    tier = "D0"
  }
}

resource "google_sql_database" "image_metadata" {
  name      = "image-metadata"
  instance  = "${google_sql_database_instance.image_metadata.name}"
  charset   = "latin1"
  collation = "latin1_swedish_ci"
}

resource "google_storage_bucket" "source_code" {
  name = "source-code"
}

resource "google_storage_bucket_object" "get_images" {
  name   = "get_images.zip"
  bucket = "${google_storage_bucket.source_code.name}"
  source = "./csharp/GetImages/GetImages.zip"
}

resource "google_cloudfunctions_function" "get_images" {
  name                  = "get-images"
  description           = "My function"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.source_code.name}"
  source_archive_object = "${google_storage_bucket_object.get_images.name}"
  trigger_http          = true
  timeout               = 60
  entry_point           = "GetImages"
  environment_variables {
    IMAGE_METADATA_CONNECTION_STRING = "${google_sql_database.image_metadata}"
  }
}

resource "google_storage_bucket_object" "get_upload_url" {
  name   = "get_uploadUrl.zip"
  bucket = "${google_storage_bucket.source_code.name}"
  source = "./csharp/GetUploadUrl/GetUploadUrl.zip"
}

resource "google_cloudfunctions_function" "get_upload_url" {
  name                  = "get-upload-url"
  description           = "My function"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.source_code.name}"
  source_archive_object = "${google_storage_bucket_object.get_upload_url.name}"
  trigger_http          = true
  timeout               = 60
  entry_point           = "GetUploadUrl"
  environment_variables {
    IMAGES_CONNECTION_STRING = "${google_storage_bucket.images}"
  }
}

resource "google_storage_bucket_object" "resize_image" {
  name   = "resize_image.zip"
  bucket = "${google_storage_bucket.source_code.name}"
  source = "./csharp/ResizeImage/ResizeImage.zip"
}

resource "google_cloudfunctions_function" "resize_image" {
  name                  = "resize_image"
  description           = "My function"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.source_code.name}"
  source_archive_object = "${google_storage_bucket_object.get_upload_url.name}"
  trigger_bucket        = "${google_storage_bucket.images.name}"
  timeout               = 60
  entry_point           = "ResizeImage"
  environment_variables {
    IMAGES_CONNECTION_STRING = "${google_storage_bucket.images}"
  }
}

resource "google_storage_bucket" "frontend" {
  name     = "frontend"
  location = "US"

  website {}
}
