terraform {
  required_version = ">= 0.14"

  required_providers {
    archive = "~> 1"
    aws     = "~> 3"
  }
}

provider "aws" {
  alias = "client_account"
}

provider "aws" {
  alias = "service_account"
}
