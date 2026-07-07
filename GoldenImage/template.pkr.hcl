cat << 'EOF' > template.pkr.hcl
packer {
  required_plugins {
    vsphere = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "ubuntu-hardened" {
  # Sanal Makine Donanim Yapilandirmasi
  vcenter_server      = "vcenter.kurumsal.int"
  username            = "packer-bot@vsphere.local"
  password            = "KurumsalSifre123!"
  insecure_connection = true

  vm_name         = "Ubuntu-26.04-Hardened-GoldenImage"
  datacenter      = "Kurumsal-Datacenter"
  cluster         = "Prod-Cluster"
  datastore       = "pure-storage-01"
  guest_os_type   = "ubuntu64Guest"
  
  cpus            = 2
  ram             = 4096
  
  network_adapters {
    network      = "VM-Network-100"
    network_card = "vmxnet3" # Kurumsal ağ optimizasyonu
  }

  # ISO Bilgileri
  iso_paths = ["[pure-storage-01] ISOs/ubuntu-26.04-live-server-amd64.iso"]

  # Otomatik Kurulum (Autoinstall / Cloud-Init) Parametreleri
  boot_command = [
    "<esc><wait>",
    "c<wait>",
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ <enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  http_directory = "http"
}

build {
  sources = ["source.vsphere-iso.ubuntu-hardened"]

  # İmaj kurulduktan sonra bizim sikilaştirma scriptimizi çaliştiran bölüm
  provisioner "shell" {
    script = "scripts/hardening.sh"
  }
}
EOF