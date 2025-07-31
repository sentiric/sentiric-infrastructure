#!/bin/bash

# Hata durumunda script'in durmasını sağla
set -e

# --- DEĞİŞKENLER ---
PROD_COMPOSE_FILE="docker-compose.prod.yml"
OVERRIDE_COMPOSE_FILE="docker-compose.override.yml"
PROFILE=${1:-all} # İlk argümanı al, yoksa 'all' varsay

# --- GİRİŞ KONTROLÜ ---
if [[ "$PROFILE" != "data" && "$PROFILE" != "telekom" && "$PROFILE" != "app" && "$PROFILE" != "ai" && "$PROFILE" != "all" ]]; then
    echo "❌ HATA: Geçersiz profil. Lütfen 'data', 'telekom', 'app', 'ai' veya 'all' kullanın."
    echo "Kullanım: ./deploy.sh [profil]"
    exit 1
fi

echo "Seçilen Profil: $PROFILE"
echo "---"

# --- ADIM 1: MEVCUT SİSTEMİ DURDUR VE TEMİZLE ---
echo "🛑 Adım 1/4: Mevcut tüm Sentiric servisleri durduruluyor ve sistem temizleniyor..."
# Sadece ilgili profildeki servisleri durdurmayı dene, yoksa tümünü
if [ "$PROFILE" == "all" ]; then
    sudo docker compose -f ${PROD_COMPOSE_FILE} down --remove-orphans || true
else
    sudo docker compose -f ${PROD_COMPOSE_FILE} --profile "$PROFILE" down --remove-orphans || true
fi
# Genel sistem temizliği sadece 'all' profilinde mantıklı.
if [ "$PROFILE" == "all" ]; then
    sudo docker system prune -a -f --volumes
fi
echo "✅ Sistem temizlendi."
echo ""

# --- ADIM 2: GEREKLİ İMAJLARI ÇEKME ---
echo "📥 Adım 2/4: Üretim imajları ghcr.io'dan çekiliyor..."
if [ "$PROFILE" == "all" ]; then
    sudo docker compose -f ${PROD_COMPOSE_FILE} pull
else
    sudo docker compose -f ${PROD_COMPOSE_FILE} --profile "$PROFILE" pull
fi
echo "✅ İmajlar başarıyla çekildi."
echo ""

# --- ADIM 3: SİSTEMİ BAŞLATMA ---
echo "🚀 Adım 3/4: Sistem '$PROFILE' profiline göre başlatılıyor..."
if [ "$PROFILE" == "all" ]; then
    # Eğer 'all' ise, mantıksal sırayla başlat
    echo "   - Veri Katmanı (data) başlatılıyor..."
    sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile data up -d
    echo "   - Uygulama Katmanı (app) başlatılıyor..."
    sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile app up -d
    echo "   - AI Katmanı (ai) başlatılıyor..."
    sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile ai up -d
    echo "   - Telekom Katmanı (telekom) başlatılıyor..."
    sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile telekom up -d
else
    # Belirli bir profil ise, sadece onu başlat
    sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile "$PROFILE" up -d
fi
echo "   - Servislerin başlaması için 20 saniye bekleniyor..."
sleep 20
echo ""

# --- ADIM 4: NİHAİ KONTROL ---
echo "🏁 Adım 4/4: Tüm sistemin durumu kontrol ediliyor..."
sudo docker ps -a
echo ""
echo "🎉 Sentiric platformu '$PROFILE' profili ile başarıyla başlatıldı!"