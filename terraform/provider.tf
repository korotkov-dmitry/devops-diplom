terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.75.0"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-diplom"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "YCAJE1qSbFQBA8PXqqtZfwk_b" 
    secret_key = "YCOV0xJ-X6otHwsGzgU_T9FiNiVQsuFR_QbsAr7b"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = "ru-central1-a"
}