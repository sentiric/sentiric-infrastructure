#!/bin/bash
set -e
set -o pipefail

# Bu script, Docker Compose için son .env dosyasını oluşturur.
# İki aşamalı bir "derleyici" gibi çalışır:
# 1. Tüm .env parçalarını birleştirir.
# 2. Birleşik dosyayı source ederek tüm değişkenleri çözer ve nihai dosyayı yazar.

PROFILE=${1:-dev}

# --- Temel Dizinleri Tanımla ---
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INFRA_DIR=$(dirname "$SCRIPT_DIR")
WORKSPACE_DIR=$(dirname "$INFRA_DIR")

# --- Kaynak ve Hedef Dosyaları Tanımla ---
CONFIG_DIR="${WORKSPACE_DIR}/sentiric-config/environments"
OUTPUT_FILE="${INFRA_DIR}/.env.generated"
PROFILE_FILE="${CONFIG_DIR}/profiles/${PROFILE}.env"
TEMP_ENV_FILE=$(mktemp)

# Başarısızlık durumunda geçici dosyayı silmek için bir tuzak kur
trap 'rm -f "$TEMP_ENV_FILE"' EXIT

if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ HATA: Profil dosyası bulunamadı: $PROFILE_FILE"
    exit 1
fi

echo "🔧 Yapılandırma dosyası '${OUTPUT_FILE}' oluşturuluyor (Profil: ${PROFILE})..."

# --- AŞAMA 1: Tüm .env parçalarını geçici dosyada topla ---
while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | tr -d '\r')
    if [[ $line == source* ]]; then
        relative_path=$(echo "$line" | cut -d' ' -f2)
        source_file="${CONFIG_DIR}/${relative_path}"
        
        if [ -f "$source_file" ]; then
            (cat "$source_file" | tr -d '\r' | grep -vE '^\s*#|^\s*$' || true) >> "$TEMP_ENV_FILE"
            echo "" >> "$TEMP_ENV_FILE"
        else
            echo "⚠️ UYARI: Kaynak dosyası bulunamadı, atlanıyor: $source_file"
        fi
    fi
done < "$PROFILE_FILE"

SECRETS_FILE="${CONFIG_DIR}/common/secrets.env"
if [ -f "$SECRETS_FILE" ]; then
    (cat "$SECRETS_FILE" | tr -d '\r' | grep -vE '^\s*#|^\s*$' || true) >> "$TEMP_ENV_FILE"
fi

# --- AŞAMA 2: Değişkenleri çöz ve nihai dosyayı yaz ---
# set -a: Tüm değişkenleri export edilebilir yap
# source: Geçici dosyayı oku ve değişkenleri çöz
# env: Çözülmüş tüm değişkenleri yazdır
# grep: Sadece bizim büyük harfli değişkenlerimizi ve TAG'ı al
# > : Nihai dosyaya yaz
(set -a; source "$TEMP_ENV_FILE"; env) | grep -E '^[A-Z_][A-Z0-9_]*=' > "$OUTPUT_FILE"

# --- Dinamik Değişkenleri Sona Ekle ---
{
    echo ""
    echo "# Dynamically added by Orchestrator"
    DETECTED_IP=$(hostname -I | awk '{print $1}' || echo "127.0.0.1")
    echo "PUBLIC_IP=${DETECTED_IP}"
    echo "TAG=${TAG:-latest}"
    echo "CONFIG_REPO_PATH=../sentiric-config"
} >> "$OUTPUT_FILE"

echo "✅ Yapılandırma başarıyla oluşturuldu."