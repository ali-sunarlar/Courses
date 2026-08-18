# AZ-104: Module 01 - Administer Identity (Kimlik Yönetimi)

AZ-104 (Microsoft Azure Administrator) sertifikasyon sınavının ilk bölümü olan **Administer Identity (Kimlik Yönetimi)** modülü, sınav sorularının yaklaşık **%15 - %20'sini** oluşturur. Bu doküman, sınav hazırlığınız ve pratik yapabilmeniz için hem **detaylı Türkçe ders notlarını** hem de altyapıyı otomatik dağıtabileceğiniz **Terraform lab kodlarını** tek bir kaynakta bir araya getirir.

---

## 📚 Bölüm 1: Detaylı Ders Notları

Bu modül iki temel ana başlıktan oluşur:
1. **Configure Azure Active Directory (Azure AD / Microsoft Entra ID Yapılandırması)**
2. **Configure User and Group Accounts (Kullanıcı ve Grup Hesaplarının Yönetimi)**

---

### 1.1 Azure Active Directory (Azure AD) Temelleri

#### Azure AD Nedir?
Azure Active Directory (güncel adıyla **Microsoft Entra ID**), Microsoft'un bulut tabanlı çok kiracılı (multi-tenant) kimlik ve erişim yönetim hizmetidir. Bulut ve şirket içi (on-premises) uygulamalara güvenli bir şekilde Single Sign-On (SSO - Tek Oturum Açma) yapılmasını sağlar.

#### Temel Kavramlar
* **Identity (Kimlik):** Doğrulanabilen (authenticated) nesnedir. Bir kullanıcı (kullanıcı adı/parola), uygulama veya servis hesabı olabilir.
* **Account (Hesap):** Bir kimliğe bağlı verilerin tutulduğu yapıdır. Kimlik olmadan hesap olamaz.
* **Azure AD Account (İş veya Okul Hesabı):** Azure AD veya Microsoft 365 üzerinde oluşturulan ve bulut hizmetlerine erişim sağlayan kimliklerdir.
* **Tenant (Kiracı / Directory):** Bir organizasyonun Microsoft bulut hizmetlerine kaydolurken aldığı özel ve adanmış Azure AD örneğidir (instance).
* **Subscription (Abonelik):** Azure kaynaklarının kullanımını ve faturalandırmasını takip eden mantıksal konteynerdir. Bir Azure AD Kiracısına birden fazla abonelik bağlanabilir.

---

### 1.2 AD DS (Geleneksel Active Directory) vs. Azure AD Karşılaştırması

| Özellik | Geleneksel AD DS (On-Premises) | Azure AD (Bulut) |
| :--- | :--- | :--- |
| **Mimari** | Hierarchical (OU yapısı var) | Flat Structure (Düz yapı, OU ve GPO **yoktur**) |
| **Sorgulama Protokolü** | LDAP / Kerberos / NTLM | REST API / HTTP(S) |
| **Kimlik Doğrulama** | Kerberos, NTLM | SAML, WS-Federation, OpenID Connect, OAuth |
| **Cihaz Yönetimi** | Group Policy Objects (GPO) | MDM (Microsoft Intune), Azure AD Join |

> 📌 **Sınav İpucu:** Azure AD bir "Sunucu/Sanal Makine" üzerinde çalışan Domain Controller değildir. Microsoft tarafından yönetilen bir PaaS / SaaS kimlik hizmetidir.

---

### 1.3 Azure AD Sürümleri (Editions)

1. **Free:** Temel kullanıcı/grup yönetimi, SSO, 500.000 nesne sınırı.
2. **Microsoft 365 Apps:** M365 abonelikleri ile gelir. Markalama, self-service parola sıfırlama (SSPR - bulut kullanıcıları için).
3. **Premium P1:** Hibrit kimlikler (Azure AD Connect), Dinamik Gruplar, Şirket içi (On-prem) kullanıcılar için Password Writeback desteği, Conditional Access (Koşullu Erişim).
4. **Premium P2:** P1'e ek olarak **Identity Protection** (Risk tabanlı erişim) ve **Privileged Identity Management (PIM)** (Tam zamanlı/Just-in-Time yönetici yetkilendirmesi) sunar.

---

### 1.4 Azure AD Join ve Cihaz Yönetimi

Cihazları Azure AD kapsamına almak için iki temel yöntem bulunurlar:
1. **Azure AD Registered:** Kişisel cihazlar (BYOD) için uygundur. Kullanıcı kendi Microsoft hesabıyla oturum açar, iş hesabını ekler.
2. **Azure AD Joined:** Kurumsal cihazlar içindir. Kullanıcılar bilgisayarlarına doğrudan kurumsal iş/okul hesaplarıyla (`user@company.com`) oturum açarlar. Windows Hello, kurumsal kaynaklara SSO ve Intune uyumluluk politikaları desteklenir.

---

### 1.5 Self-Service Password Reset (SSPR)

Kullanıcıların bilgi işlem destek ekibine (Helpdesk) ihtiyaç duymadan parolalarını sıfırlamalarını sağlar.
* **Kapsam:** `None`, `Selected` (Test grupları için) veya `All` olarak seçilebilir.
* **Doğrulama Yöntemleri:** E-posta, SMS/Arama, Mobil Uygulama Bildirimi/Kodu, Güvenlik Soruları.

---

### 1.6 Kullanıcı ve Grup Yönetimi

#### Kullanıcı Türleri
1. **Cloud Identities:** Doğrudan Azure AD üzerinde oluşturulan hesaplardır.
2. **Directory-Synchronized Identities:** Şirket içi Active Directory'den Azure AD Connect ile senkronize edilen hesaplardır.
3. **Guest Users (B2B):** Dış organizasyonlardan veya kişisel Microsoft hesaplarından davet edilen konuk kullanıcılardır.

> 🗑️ **Silinen Kullanıcılar:** Silinen bir kullanıcı hesabı **30 gün** boyunca "Deleted Users" alanında saklanır ve bu süre içinde geri yüklenebilir (Soft Delete).

---

#### Grup Türleri ve Üyelik Tipleri

* **Grup Türleri:**
  * **Security Groups:** Kaynaklara erişim yetkisi dağıtmak için kullanılır.
  * **Microsoft 365 Groups:** E-posta, Teams, SharePoint ve takvim paylaşımı gibi ortak çalışma için kullanılır.

* **Üyelik Tipleri (Membership Types):**
  * **Assigned:** Kullanıcılar elle gruba eklenir.
  * **Dynamic User:** Kullanıcı özniteliklerine (Department, Job Title gibi) göre otomatik kural ile eklenir (P1 lisans gerektirir).
  * **Dynamic Device:** Cihaz özniteliklerine göre otomatik eklenir.

---

#### Administrative Units (Yönetsel Birimler)
Organizasyon içindeki yönetim yetkilerini sınırlandırmak için kullanılır (Örn: Sadece Mühendislik Fakültesi kullanıcılarını yönetebilen bir alt yetkili atamak).

---

## 🛠️ Bölüm 2: Terraform Lab Ortamı

Bu bölüm, yukarıda öğrenilen teorik konuları (Kullanıcılar, Dinamik ve Atamalı Gruplar, Administrative Unit) Azure ortamında test edebilmeniz için hazırlanan IaC (Infrastructure as Code) kodunu içerir.

### 2.1 Ön Gereksinimler
1. Bilgisayarınızda **Terraform** (>= 1.0.0) ve **Azure CLI (`az`)** kurulu olmalıdır.
2. Terminalinizden `az login` komutu ile Azure hesabınıza giriş yapılmış olmalıdır.

---

### 2.2 Terraform Kod Bloğu (`main.tf`)

```hcl
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

# 1. Kiracı Domain Bilgisini Alma
data "azuread_domains" "default" {
  only_initial = true
}

locals {
  domain_name = data.azuread_domains.default.domains[0].domain_name
}

# 2. Kullanıcı 1: Cloud Administrator (Dinamik Gruba Düşecek)
resource "azuread_user" "user1" {
  user_principal_name   = "az104-01a-user1@${local.domain_name}"
  display_name          = "AZ104 Cloud Admin User"
  mail_nickname         = "az104-01a-user1"
  password              = "P@ssw0rd123456!"
  job_title             = "Cloud Administrator"
  department            = "IT"
  force_password_change = true
}

# 3. Kullanıcı 2: System Administrator (Atamalı Gruba Düşecek)
resource "azuread_user" "user2" {
  user_principal_name   = "az104-01a-user2@${local.domain_name}"
  display_name          = "AZ104 System Admin User"
  mail_nickname         = "az104-01a-user2"
  password              = "P@ssw0rd123456!"
  job_title             = "System Administrator"
  department            = "IT"
  force_password_change = true
}

# 4. Dinamik Güvenlik Grubu (Job Title = Cloud Administrator olanlar otomatik eklenir)
resource "azuread_group" "dynamic_group" {
  display_name     = "IT Cloud Administrators"
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.jobTitle -eq "Cloud Administrator""
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
```

---

### 2.3 Lab Kurulum ve Doğrulama Adımları

1. Kodları bilgisayarınızda bir klasöre `main.tf` olarak kaydedin.
2. Terminalden ilgili klasöre geçip bağımlılıkları yükleyin:
   ```bash
   terraform init
   ```
3. Oluşturulacak kaynakları kontrol edin:
   ```bash
   terraform plan
   ```
4. Lab ortamını Azure üzerinde dağıtın:
   ```bash
   terraform apply
   ```
5. **Azure Portal Doğrulaması:**
   * **Microsoft Entra ID > Users:** `az104-01a-user1` ve `az104-01a-user2` hesaplarını kontrol edin.
   * **Microsoft Entra ID > Groups:** `IT Cloud Administrators` dinamik grubunda `user1`'in otomatik üye olduğunu, `IT Systems Group` grubunda ise `user2`'nin ekli olduğunu doğrulayın.
   * **Microsoft Entra ID > Administrative units:** `IT Department AU` içerisinde `user1` hesabı yer almalıdır.

### 2.4 Temizlik
Pratik çalışmanız tamamlandıktan sonra kaynakları silmek için:
```bash
terraform destroy
```
