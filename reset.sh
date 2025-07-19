#!/bin/bash
# Sentiric Platformu için Docker Temizleme ve Sıfırlama Script'i
# DİKKAT: Bu script, bu proJEYE AİT OLMAYANLAR DA DAHİL OLMAK ÜZERE
# SİSTEMDEKİ TÜM DURDURULMUŞ KONTEYNERLERİ, KULLANILMAYAN İMAJLARI,
# VOLUMELARI VE AĞLARI KALICI OLARAK SİLER.

set -e

echo "======================================================"
echo "    Sentiric Docker Ortamı - Sıfırlama Aracı    "
echo "======================================================"
echo ""

# Adım 1: docker-compose ile yönetilen tüm servisleri durdur ve kaldır.
# Bu, sadece bu projenin konteynerlerini hedefler.
if [ -f "docker-compose.yml" ]; then
    echo "-> docker-compose.yml bulundu. Mevcut Sentiric servisleri durduruluyor ve kaldırılıyor..."
    docker compose down --volumes
    echo "-> Sentiric servisleri başarıyla kaldırıldı."
else
    echo "-> UYARI: docker-compose.yml bulunamadı, bu adım atlanıyor."
fi

echo ""
echo "-> Sistem genelinde Docker temizliği başlatılıyor..."
echo "   (Bu işlem diğer projelerinizi etkileyebilir, dikkatli olun!)"
echo ""

# Adım 2: Genel Docker temizliği yap.
# docker system prune, durdurulmuş tüm konteynerleri, kullanılmayan ağları,
# isimsiz (dangling) imajları ve build cache'ini temizler.
# -a: Kullanılmayan imajları da (sadece isimsiz olanları değil) temizler.
# -f: Onay istemeden çalıştırır.
echo "-> 'docker system prune -a -f' çalıştırılıyor..."
docker system prune -a -f

# Adım 3: İsimsiz (dangling) volumeları temizle.
# 'docker system prune' bazen bunları atlayabilir.
if [ -n "$(docker volume ls -qf dangling=true)" ]; then
    echo "-> İsimsiz Docker volumeları temizleniyor..."
    docker volume prune -f
else
    echo "-> Temizlenecek isimsiz volume bulunamadı."
fi


echo ""
echo "======================================================"
echo "✅ Docker ortamı başarıyla sıfırlandı!"
echo "   Artık 'start.sh' ile temiz bir kurulum yapabilirsiniz."
echo "======================================================"