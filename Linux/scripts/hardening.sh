cat << 'EOF' > scripts/hardening.sh
#!/bin/bash
set -e

echo "=== Kurumsal Hardening ve Sikilaştirma Başliyor ==="

# 1. Zayif SSH Algoritmalarinin Kapatilmasi (Sweet32 ve Zayif Şifreleme Bloklari Çözümü)
echo "[-] SSH Yapilandirmasi Sikilaştiriliyor..."
sudo sed -i '/^#\?Ciphers/d' /etc/ssh/sshd_config
sudo sed -i '/^#\?KexAlgorithms/d' /etc/ssh/sshd_config

echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com" | sudo tee -a /etc/ssh/sshd_config
echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512" | sudo tee -a /etc/ssh/sshd_config
echo "MACs hmac-sha2-512-etm@openssh.com" | sudo tee -a /etc/ssh/sshd_config

# 2. Güvenli LDAP (LDAPS) ve LDAP Signing (İmzalama) Zorunluluğu
echo "[-] LDAP İstemci Güvenliği Artiriliyor..."
sudo sed -i 's/^#\?TLS_REQCERT.*/TLS_REQCERT demand/' /etc/ldap/ldap.conf
echo "LDAP_REFERRALS off" | sudo tee -a /etc/ldap/ldap.conf

# 3. TLS 1.2 altindaki tüm eski protokollerin sistem genelinde (OpenSSL) yasaklanmasi
echo "[-] Sistem Genelinde TLS 1.3 ve TLS 1.2 Minimum Standart Yapiliyor..."
sudo sed -i 's/MinProtocol = .*/MinProtocol = TLSv1.2/' /etc/ssl/openssl.cnf
sudo sed -i 's/CipherString = .*/CipherString = DEFAULT@SECLEVEL=2/' /etc/ssl/openssl.cnf

# 4. Kurumsal Güvenlik Güncellemelerinin (Unattended-Upgrades) Aktif Edilmesi
echo "[-] Otomatik Güvenlik Yamalari Devreye Aliniyor..."
sudo apt-get install -y unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.get/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.get/20auto-upgrades

sudo systemctl restart ssh
echo "=== Hardening İşlemleri Başariyla Tamamlandi ==="
EOF

chmod +x scripts/hardening.sh