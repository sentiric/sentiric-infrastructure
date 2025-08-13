#!/bin/bash
set -e

PROFILE=${1:-dev}
CONFIG_DIR="../sentiric-config/environments"
OUTPUT_FILE=".env.generated"
SECRETS_FILE="${CONFIG_DIR}/common/secrets.env"
PROFILE_FILE="${CONFIG_DIR}/profiles/${PROFILE}.env"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ HATA: Profil dosyası bulunamadı: $PROFILE_FILE"
    exit 1
fi

echo "🔧 Yapılandırma dosyası '${OUTPUT_FILE}' oluşturuluyor (Profil: ${PROFILE})..."

# Kaynak profil dosyasını kopyala
cp "$PROFILE_FILE" "$OUTPUT_FILE"

# Sırları (secrets) ekle, eğer varsa
if [ -f "$SECRETS_FILE" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "# Included from: secrets.env" >> "$OUTPUT_FILE"
    # secrets.env içindeki yorum satırlarını ve boş satırları atla
    grep -v '^#' "$SECRETS_FILE" | grep -v '^$' >> "$OUTPUT_FILE"
fi

# Dinamik değişkenleri ekle
echo "" >> "$OUTPUT_FILE"
echo "# Dynamically added by Orchestrator" >> "$OUTPUT_FILE"
DETECTED_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || hostname -I | awk '{print $1}')
echo "PUBLIC_IP=${DETECTED_IP}" >> "$OUTPUT_FILE"
TAG=${TAG:-latest}
echo "TAG=${TAG}" >> "$OUTPUT_FILE"
# CONFIG_REPO_PATH değişkenini de ekleyerek Docker Compose'un bulmasını garanti et
echo "CONFIG_REPO_PATH=../sentiric-config" >> "$OUTPUT_FILE"

echo "✅ Yapılandırma başarıyla oluşturuldu."