provider "aws" {}

resource "aws_s3_bucket" "images" {
  bucket_prefix = "images"
  acl           = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["*"]
  }
}

resource "aws_s3_bucket" "thumbnails" {
  bucket_prefix = "thumbnails"
  acl           = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["*"]
  }
}

resource "aws_dynamodb_table" "image_metadata" {
  name           = "images"
  hash_key       = "id"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "imgPath"
    type = "S"
  }

  attribute {
    name = "imgPath"
    type = "S"
  }

  attribute {
    name = "thumbnailPath"
    type = "S"
  }

  attribute {
    name = "description"
    type = "S"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "get_images" {
  function_name = "GetImages"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  runtime       = "nodejs8.10"
  filename      = "GetImages.zip"
  handler       = "exports.GetImages"

  environment {
    variables {
      IMAGE_METADATA_ID = "${aws_dynamodb_table.image_metadata.id}"
    }
  }
}

resource "aws_lambda_function" "get_upload_url" {
  function_name = "GetUploadUrl"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  runtime       = "nodejs8.10"
  filename      = "GetUploadUrl.zip"
  handler       = "exports.GetUploadUrl"
}

resource "aws_lambda_function" "resize_image" {
  function_name = "ResizeImage"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  runtime       = "nodejs8.10"
  filename      = "ResizeImage.zip"
  handler       = "exports.ResizeImage"
}

resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "frontend"
  acl           = "public-read"

  website {
    # content = "www/dist"
    index_document = "index.html"
  }
}
