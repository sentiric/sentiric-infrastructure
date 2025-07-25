#!/bin/bash

SERVER_TYPE=$1
SERVER_IP=$2

case $SERVER_TYPE in
  data)
    ENV_FILE="configs/prod/.env.data"
    PROFILES="data"
    ;;
  app)
    ENV_FILE="configs/prod/.env.app" 
    PROFILES="app"
    ;;
  telekom)
    ENV_FILE="configs/prod/.env.telekom"
    PROFILES="telekom"
    ;;
  *)
    echo "Usage: $0 [data|app|telekom] [IP]"
    exit 1
esac

# Sunucuya dosyaları kopyala
rsync -avz \
  --exclude='.git' \
  --exclude='configs/prod' \
  . $SERVER_IP:/sentiric/

# Uzaktan çalıştır
ssh $SERVER_IP "
  mkdir -p /sentiric/configs/prod
  echo 'Copying ENV file...'
  cp /sentiric/.env.prod.example /sentiric/$ENV_FILE
  cd /sentiric && docker compose --profile $PROFILES up -d --build
"