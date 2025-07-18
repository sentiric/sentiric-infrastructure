#!/bin/bash

# Hata durumunda script'in çalışmasını durdurur.
set -e

echo "======================================================"
echo "    Sentiric Altyapısı - Sunucu İlk Kurulum Script'i    "
echo "======================================================"
echo "Bu script, Docker ve Docker Compose'u kuracak."
echo ""

# Adım 1: Sistemi güncelle ve gerekli temel paketleri kur.
echo "--> Adım 1/5: Paket listesi güncelleniyor ve temel bağımlılıklar kuruluyor..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Adım 2: Docker'ın resmi GPG anahtarını ekle.
echo "--> Adım 2/5: Docker GPG anahtarı ekleniyor..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Adım 3: Docker'ın paket deposunu sisteme ekle.
echo "--> Adım 3/5: Docker APT deposu yapılandırılıyor..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Adım 4: Docker Engine ve Compose eklentisini kur.
echo "--> Adım 4/5: Docker Engine ve Compose eklentisi kuruluyor..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adım 5: Mevcut kullanıcıyı 'docker' grubuna ekle.
echo "--> Adım 5/5: Kullanıcı '${USER}' docker grubuna ekleniyor..."
sudo usermod -aG docker ${USER}

echo ""
echo "========================================================================"
echo "✅ Kurulum Başarıyla Tamamlandı!"
echo ""
echo "‼️ ÖNEMLİ: Değişikliklerin etkili olması için bu SSH oturumunu kapatıp"
echo "   sunucuya TEKRAR GİRİŞ YAPMANIZ gerekmektedir."
echo ""
echo "Tekrar giriş yaptıktan sonra 'docker compose up -d' komutunu çalıştırabilirsiniz."
echo "========================================================================"
echo ""