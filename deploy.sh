#!/bin/bash

# Hata durumunda script'in durmasını sağla
set -e

# --- DEĞİŞKENLER ---
PROD_COMPOSE_FILE="docker-compose.prod.yml"
OVERRIDE_COMPOSE_FILE="docker-compose.override.yml"

# --- ADIM 1: MEVCUT SİSTEMİ TAMAMEN DURDUR VE TEMİZLE ---
echo "🛑 Adım 1/4: Mevcut tüm Sentiric servisleri durduruluyor ve sistem temizleniyor..."
# DÜZELTME: docker-compose -> docker compose
sudo docker compose -f ${PROD_COMPOSE_FILE} down --remove-orphans || true
sudo docker system prune -a -f --volumes
echo "✅ Sistem temizlendi."
echo ""

# --- ADIM 2: GEREKLİ İMAJLARI ÇEKME ---
echo "📥 Adım 2/4: Üretim imajları ghcr.io'dan çekiliyor..."
# DÜZELTME: docker-compose -> docker compose
sudo docker compose -f ${PROD_COMPOSE_FILE} pull
echo "✅ İmajlar başarıyla çekildi."
echo ""

# --- ADIM 3: SİSTEMİ KADEMELİ OLARAK BAŞLATMA ---
echo "🚀 Adım 3/4: Sistem profillere göre kademeli olarak başlatılıyor..."
echo ""

# 3.1: Veri Katmanı
echo "   - Veri Katmanı (data) başlatılıyor..."
# DÜZELTME: docker-compose -> docker compose
sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile data up -d
echo "   - Sağlık kontrolleri için 30 saniye bekleniyor..."
sleep 30
sudo docker ps -a --filter "label=com.docker.compose.project.profile=data"
echo "   - Veri Katmanı başlatıldı."
echo ""

# 3.2: Uygulama Katmanı
echo "   - Uygulama Katmanı (app) başlatılıyor..."
# DÜZELTME: docker-compose -> docker compose
sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile app up -d
echo "   - Uygulama servislerinin başlaması için 20 saniye bekleniyor..."
sleep 20
sudo docker ps -a --filter "label=com.docker.compose.project.profile=app"
echo "   - Uygulama Katmanı başlatıldı."
echo ""

# 3.3: Telekom Katmanı
echo "   - Telekom Katmanı (telekom) başlatılıyor..."
# DÜZELTME: docker-compose -> docker compose
sudo docker compose -f ${PROD_COMPOSE_FILE} -f ${OVERRIDE_COMPOSE_FILE} --profile telekom up -d
echo "   - Telekom servislerinin başlaması için 15 saniye bekleniyor..."
sleep 15
sudo docker ps -a --filter "label=com.docker.compose.project.profile=telekom"
echo "   - Telekom Katmanı başlatıldı."
echo ""

# --- ADIM 4: NİHAİ KONTROL ---
echo "🏁 Adım 4/4: Tüm sistemin durumu kontrol ediliyor..."
sudo docker ps -a
echo ""
echo "🎉 Sentiric platformu başarıyla başlatıldı!"