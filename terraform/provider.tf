provider "aws" {
  region = var.REGION

  # Note: keys reading from ENV
  # access_key = var.AWS_ACCESS_KEY_ID
  # secret_key = var.AWS_SECRET_ACCESS_KEY
}