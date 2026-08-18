terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40.0"
    }
  }
}

provider "azuread" {}

# 1. Kiracı Domain Bilgisini Alalım
data "azuread_domains" "default" {
  only_initial = true
}

locals {
  domain_name = data.azuread_domains.default.domains[0].domain_name
}

# 2. Kullanıcı 1: Cloud Administrator (Dinamik Gruba Düşecek)
resource "azuread_user" "user1" {
  user_principal_name = "az104-01a-user1@${local.domain_name}"
  display_name        = "AZ104 Cloud Admin User"
  mail_nickname       = "az104-01a-user1"
  password            = "P@ssw0rd123456!"
  job_title           = "Cloud Administrator"
  department          = "IT"
  force_password_change = true
}

# 3. Kullanıcı 2: System Administrator (Dinamik Gruba Düşecek)
resource "azuread_user" "user2" {
  user_principal_name = "az104-01a-user2@${local.domain_name}"
  display_name        = "AZ104 System Admin User"
  mail_nickname       = "az104-01a-user2"
  password            = "P@ssw0rd123456!"
  job_title           = "System Administrator"
  department          = "IT"
  force_password_change = true
}

# 4. Dinamik Güvenlik Grubu (Job Title = Cloud Administrator olanlar otomatik eklenir)
resource "azuread_group" "dynamic_group" {
  display_name     = "IT Cloud Administrators"
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.jobTitle -eq \"Cloud Administrator\""
  }
}

# 5. Elle Atamalı (Assigned) Güvenlik Grubu
resource "azuread_group" "assigned_group" {
  display_name     = "IT Systems Group"
  security_enabled = true
}

# 6. Kullanıcı 2'yi Elle Atamalı Gruba Ekleme
resource "azuread_group_member" "member_user2" {
  group_object_id  = azuread_group.assigned_group.object_id
  member_object_id = azuread_user.user2.object_id
}

# 7. Administrative Unit (Yönetsel Birim) Oluşturma
resource "azuread_administrative_unit" "it_au" {
  display_name = "IT Department AU"
  description  = "Administrative Unit for IT Personnel"
}

# 8. Kullanıcı 1'i Administrative Unit'e Ekleme
resource "azuread_administrative_unit_member" "au_member" {
  administrative_unit_object_id = azuread_administrative_unit.it_au.id
  member_object_id              = azuread_user.user1.object_id
}

output "created_users" {
  value = [
    azuread_user.user1.user_principal_name,
    azuread_user.user2.user_principal_name
  ]
}