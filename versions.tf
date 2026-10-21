terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}