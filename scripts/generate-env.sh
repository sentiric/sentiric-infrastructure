#!/bin/bash
set -e

PROFILE=${1:-dev}
CONFIG_DIR="../sentiric-config/environments"
OUTPUT_FILE=".env.generated"
SECRETS_FILE="${CONFIG_DIR}/common/secrets.env"
PROFILE_FILE="${CONFIG_DIR}/profiles/${PROFILE}.env"

echo "# Auto-generated for profile: ${PROFILE}" > "$OUTPUT_FILE"
cat "$PROFILE_FILE" >> "$OUTPUT_FILE"

if [ -f "$SECRETS_FILE" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "# Included from: secrets.env" >> "$OUTPUT_FILE"
    cat "$SECRETS_FILE" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "# Dynamically added by Orchestrator" >> "$OUTPUT_FILE"
DETECTED_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || hostname -I | awk '{print $1}')
echo "PUBLIC_IP=${DETECTED_IP}" >> "$OUTPUT_FILE"
TAG=${TAG:-latest}
echo "TAG=${TAG}" >> "$OUTPUT_FILE"

echo "✅ Yapılandırma dosyası '${OUTPUT_FILE}' başarıyla oluşturuldu (Profil: ${PROFILE})."