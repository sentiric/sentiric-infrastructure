#!/bin/bash
# Sentiric Platformu için Aşamalı Başlatma Script'i
# Bu script, kaynakları kısıtlı sistemlerde (örn: e2-micro)
# servislerin sağlıklı bir şekilde başlamasını sağlamak için tasarlanmıştır.

# Hata durumunda script'in çalışmasını durdurur.
set -e

echo "======================================================"
echo "    Sentiric Platformu - Aşamalı Başlatıcı    "
echo "======================================================"

# Adım 1: Mevcut çalışan tüm konteynerleri temiz bir başlangıç için durdur
if [ "$(docker ps -q)" ]; then
    echo "-> Mevcut çalışan konteynerler durduruluyor..."
    docker compose down
else
    echo "-> Çalışan konteyner bulunamadı, temiz başlangıç."
fi

echo ""
echo "--- KATMAN 1: Temel Altyapı Başlatılıyor ---"
docker compose up -d postgres redis rabbitmq
echo "-> Altyapı servislerinin kendine gelmesi için 15 saniye bekleniyor..."
sleep 15
docker compose ps # Durumu göster

echo ""
echo "--- KATMAN 2: Bağımsız Uygulama Servisleri Başlatılıyor ---"
docker compose up -d user-service dialplan-service media-service
echo "-> Uygulama servislerinin kendine gelmesi için 10 saniye bekleniyor..."
sleep 10
docker compose ps # Durumu göster

echo ""
echo "--- KATMAN 3: Akıllı Servis (Agent) Başlatılıyor ---"
docker compose up -d agent-service
echo "-> Agent servisinin kendine gelmesi için 10 saniye bekleniyor..."
sleep 10
docker compose ps # Durumu göster

echo ""
echo "--- KATMAN 4: Dış Dünya Kapısı (SIP) Başlatılıyor ---"
docker compose up -d sip-signaling
echo "-> SIP servisinin kendine gelmesi için 5 saniye bekleniyor..."
sleep 5

echo ""
echo "======================================================"
echo "✅ Tüm Sentiric servisleri başarıyla başlatıldı!"
echo "======================================================"
docker compose ps