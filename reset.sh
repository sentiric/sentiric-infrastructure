#!/bin/bash

echo "Tüm konteynerler durduruluyor..."
docker stop $(docker ps -q) 2>/dev/null

echo "Tüm konteynerler siliniyor..."
docker rm -f $(docker ps -aq) 2>/dev/null

echo "Tüm imajlar siliniyor..."
docker rmi -f $(docker images -aq) 2>/dev/null

echo "Dangling (etiketsiz) imajlar siliniyor..."
docker image prune -af 2>/dev/null

echo "Tüm volume'lar siliniyor..."
docker volume rm -f $(docker volume ls -q) 2>/dev/null
docker volume prune -f 2>/dev/null

echo "Tüm network'ler siliniyor (default olanlar hariç)..."
docker network rm $(docker network ls | grep -v "bridge\|host\|none" | awk '{print $1}' | tail -n +2) 2>/dev/null
docker network prune -f 2>/dev/null

echo "Builder cache temizleniyor..."
docker builder prune -af --force 2>/dev/null

echo "Context'ler siliniyor (default hariç)..."
for ctx in $(docker context ls --format '{{.Name}}' | grep -v default); do
    docker context rm -f $ctx 2>/dev/null
done

echo "Docker ortamı tamamen sıfırlandı!"