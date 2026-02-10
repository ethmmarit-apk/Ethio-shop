terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_sql_database_instance" "main" {
  name             = "ethio-marketplace-db"
  database_version = "POSTGRES_15"
  region           = var.region
  
  settings {
    tier = var.db_tier
    disk_size = var.db_disk_size
    
    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_redis_instance" "cache" {
  name           = "ethio-marketplace-redis"
  tier           = var.redis_tier
  memory_size_gb = var.redis_memory_size
  region         = var.region
}

resource "google_storage_bucket" "uploads" {
  name          = "${var.project_id}-uploads"
  location      = var.region
  storage_class = "STANDARD"
}

resource "google_cloud_run_service" "api" {
  name     = "ethio-marketplace-api"
  location = var.region
  
  template {
    spec {
      containers {
        image = var.api_image
      }
    }
  }
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 10
}

variable "redis_tier" {
  description = "Redis instance tier"
  type        = string
  default     = "BASIC"
}

variable "redis_memory_size" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}

variable "api_image" {
  description = "Docker image for API"
  type        = string
  default     = "gcr.io/ethio-marketplace/api:latest"
}