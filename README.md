# 🚀 Sentiric Platform Orchestration Hub

**Tek compose dosyasıyla tüm ortam yönetimi** - Yerel geliştirmeden çok sunuculu üretim ortamlarına kadar her senaryoyu destekler

## 📌 Önemli Özellikler
- **Tek bir compose dosyası** ile tüm servis yönetimi
- **Profile tabanlı** dağıtım (data/app/telekom)
- **Hem yerel hem de prod** ortam desteği
- **Dinamik bağımlılık yönetimi** ile esnek yapı
- **Otomatik deploy scriptleri** ile kolay dağıtım

## 📂 Dosya Yapısı
```
sentiric-infrastructure/
├── docker-compose.yml          # Ana compose dosyası
├── .env.local.example          # Yerel ortam örneği

```

## 🛠️ Kurulum

### 1. Önkoşullar
- Docker 20.10+
- Docker Compose 2.0+
- Git

### 2. Tüm Repoları Klonla
```bash
git clone https://github.com/sentiric/sentiric-infrastructure.git
git clone https://github.com/sentiric/sentiric-user-service.git
# Diğer servis repolarını da klonlayın...
```

## 🖥️ Yerel Geliştirme

### 1. Ortamı Hazırla
```bash
cp .env.local.example configs/local/.env
# .env dosyasını ihtiyacınıza göre düzenleyin
```

### 2. Servisleri Başlat


# Veya belirli profillerle:
```bash
docker compose --profile data up -d
docker compose --profile app up -d
docker compose --profile telekom up -d
```

Tüm servisleri başlat
```bash
docker-compose --profile default  up --build -d
```

### 3. Servisleri Durdur
```bash
docker-compose  --profile default  down -v
```


## 🌐 Servis Dağılımı

| Sunucu Tipi   | Servisler                          | Profile |
|---------------|------------------------------------|---------|
| **Data**      | PostgreSQL, RabbitMQ, Redis, MongoDB | data    |
| **App**       | User, Dialplan, Agent, Analytics   | app     |
| **Telekom**   | SIP Signaling, Media Service       | telekom |

