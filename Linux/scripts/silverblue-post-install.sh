#!/usr/bin/env bash
# ==============================================================================
# Fedora Silverblue - Saf 64-Bit Gömülü Linux Ortami & VS Code Kurulum Betiği (V2)
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo "--> 1. Host bağimliliklari kontrol ediliyor..."
if ! command -v distrobox &> /dev/null; then
    echo "Distrobox bulunamadi! Lütfen host sistemine kurun."
    exit 1
fi

echo "--> 2. Geliştirme dizini hazirlaniyor (~/Repos)..."
mkdir -p "$HOME/Repos"

BOX_NAME="embedded-dev"
echo "--> 3. '$BOX_NAME' isimli Ubuntu konteyneri oluşturuluyor..."
if distrobox list | grep -q "$BOX_NAME"; then
    echo "   [!] $BOX_NAME zaten mevcut."
else
    distrobox create --image ubuntu:latest --name "$BOX_NAME" --yes
fi

echo "--> 4. Konteyner içi paket kurulumlari ve VS Code imza çözümü başlatiliyor..."
CONTAINER_SETUP_SCRIPT=$(cat << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "   [Con] Paket listeleri güncelleniyor..."
sudo apt-get update
sudo apt-get install -y wget gpg apt-transport-https coreutils

echo "   [Con] Microsoft GPG anahtari güvenli keyring dizinine çekiliyor..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null

echo "   [Con] Microsoft VS Code depo listesi oluşturuluyor..."
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

echo "   [Con] Güncel depolarla paket kurulumlari yapiliyor..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    debootstrap \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    libcrypt-dev:arm64 \
    code

echo "   [Con] Toybox derleme kolayliği için sembolik bağ oluşturuluyor..."
sudo ln -sf /usr/bin/aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-cc

echo "   [Con] VS Code, Host masaüstü menüsüne ihraç ediliyor (Kullanici moduyla)..."
# Root yetkisinden çikip normal kullanici komutu olarak çağrilmasini sağliyoruz
distrobox-export --app code

echo "   [Con] Konteyner içi yapilandirma başariyla tamamlandi!"
EOF
)

echo "--> 5. Komutlar konteyner içinde koşturuluyor..."
distrobox enter "$BOX_NAME" -- bash -c "$CONTAINER_SETUP_SCRIPT"

echo "=========================================================="
echo "🎉 İŞLEM TAMAMLANDI!"
echo "Microsoft imza hatasi aşildi ve VS Code başariyla kuruldu."
echo "Menüden VS Code'u başlatabilir veya terminalden 'distrobox enter $BOX_NAME' ile dalabilirsin."
echo "=========================================================="
