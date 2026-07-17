#!/usr/bin/env bash
# ==============================================================================
# Fedora Silverblue - Çift Dünyalı (x64 & Saf ARM64) Geliştirme Ortamı Kurulumu
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo "--> 1. Host bağımlılıkları kontrol ediliyor..."
if ! command -v distrobox &> /dev/null; then
    echo "Distrobox bulunamadı! Lütfen host sistemine kurun."
    exit 1
fi

# ARM emülasyonu için host sistemde qemu-user-static kontrolü (Silverblue'da kontrol)
# Eğer qemu paketleri eksikse binfmt tetiklenemez
if ! rpm-ostree status | grep -q "qemu-user-static" && [ ! -f /usr/bin/qemu-aarch64-static ]; then
    echo "[!] DİKKAT: Host üzerinde ARM64 emülasyonu için qemu-user-static eksik olabilir."
    echo "    Eğer arm64 konteyneri başlamazsa hostta şunu çalıştırın: rpm-ostree install qemu-user-static && reboot"
fi

echo "--> 2. Geliştirme dizini hazırlanıyor (~/Repos)..."
mkdir -p "$HOME/Repos"


# ==============================================================================
# ORTAM 1: embedded-dev-arm (Native x64 Host Dünyası & VS Code)
# ==============================================================================
BOX_X64="embedded-dev-arm"
echo "--> 3. '$BOX_X64' (x64) konteyneri kontrol ediliyor..."
if distrobox list | grep -q "$BOX_X64"; then
    echo "   [!] $BOX_X64 zaten mevcut."
else
    distrobox create --image ubuntu:latest --name "$BOX_X64" --yes
    
    echo "--> 4. $BOX_X64 içi paket kurulumları ve VS Code yapılandırması..."
    X64_SCRIPT=$(cat << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y wget gpg apt-transport-https coreutils
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt-get update
sudo apt-get install -y build-essential git debootstrap gcc-aarch64-linux-gnu g++-aarch64-linux-gnu libcrypt-dev:arm64 code
sudo ln -sf /usr/bin/aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-cc
distrobox-export --app code
EOF
)
    distrobox enter "$BOX_X64" -- bash -c "$X64_SCRIPT"
fi


# ==============================================================================
# ORTAM 2: embedded-arm64 (Saf 64-Bit ARM Emüle Dünyası)
# ==============================================================================
BOX_ARM="embedded-arm64"
echo "--> 5. '$BOX_ARM' (ARM64) konteyneri oluşturuluyor..."
if distrobox list | grep -q "$BOX_ARM"; then
    echo "   [!] $BOX_ARM zaten mevcut."
else
    # İŞTE EN KRİTİK NOKTA: --additional-flags "--platform linux/arm64" 
    # Podman'e görüntüyü zorla arm64 mimarisinde çekmesini ve emüle etmesini söyler.
    distrobox create --image ubuntu:latest --name "$BOX_ARM" --additional-flags "--platform linux/arm64" --yes

    echo "--> 6. $BOX_ARM (ARM64) içi yerel paket kurulumları başlatılıyor..."
    ARM_SCRIPT=$(cat << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "   [ARM-Con] Paket listeleri güncelleniyor (ports.ubuntu.com otomatik devrede)..."
sudo apt-get update

echo "   [ARM-Con] Native ARM64 geliştirme araçları kuruluyor..."
# Bu konteyner zaten ARM64 olduğu için çapraz derleyiciye GEREK YOK! Normal gcc kuruyoruz.
sudo apt-get install -y build-essential git debootstrap htop

echo "   [ARM-Con] Mimari doğrulaması yapılıyor..."
echo "   [ARM-Con] İçerideki güncel mimari: $(uname -m)"
EOF
)
    distrobox enter "$BOX_ARM" -- bash -c "$ARM_SCRIPT"
fi

echo "=========================================================="
echo "🎉 MUAZZAM! ÇİFT LABORATUVARINIZ HAZIR!"
echo "----------------------------------------------------------"
echo "1. Ana Geliştirme Alanı (x64):"
echo "   Kullanım: distrobox enter $BOX_X64"
echo "   (Çapraz derleyiciler ve masaüstünüze bağlı VS Code burada)"
echo ""
echo "2. Saf ARM64 Laboratuvarı (Emüle ARM64):"
echo "   Kullanım: distrobox enter $BOX_ARM"
echo "   (İçeride uname -m yaptığında aarch64 göreceksin!)"
echo "=========================================================="