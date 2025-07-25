#!/bin/bash

# Config ayarla
cp .env.local.example configs/local/.env

# Tüm servisleri başlat (veya profile göre)
docker compose --profile all up -d --build

# Alternatif kullanımlar:
# docker compose --profile app up -d
# docker compose --profile telekom up -d