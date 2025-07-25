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
├── .env.prod.example           # Prod ortam örneği
├── configs/
│   ├── prod/                   # Gerçek prod configleri (gitignore)
│   └── local/                  # Yerel configler (gitignore)
└── scripts/
    ├── deploy-local.sh         # Yerel ortam kurulumu
    └── deploy-prod.sh          # Prod dağıtım scripti
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
```bash
# Tüm servisler (full stack)
./scripts/deploy-local.sh

# Veya belirli profillerle:
docker compose --profile data up -d
docker compose --profile app up -d
docker compose --profile telekom up -d
```

### 3. Servisleri Durdur
```bash
docker compose down
```

## ☁️ Üretim Dağıtımı

### 1. Sunucuları Hazırla
```bash
# Örnek: Data sunucusuna kurulum
./scripts/deploy-prod.sh data 192.168.1.100

# App sunucusu
./scripts/deploy-prod.sh app 192.168.1.101

# Telekom sunucusu
./scripts/deploy-prod.sh telekom 192.168.1.102
```

### 2. Ortam Yapılandırması
Her sunucuda `configs/prod/` altındaki ilgili .env dosyasını düzenleyin:
- `.env.data` - PostgreSQL, RabbitMQ ayarları
- `.env.app` - Uygulama servisleri ayarları
- `.env.telekom` - SIP/Media servis ayarları

## 🌐 Servis Dağılımı

| Sunucu Tipi   | Servisler                          | Profile |
|---------------|------------------------------------|---------|
| **Data**      | PostgreSQL, RabbitMQ, Redis, MongoDB | data    |
| **App**       | User, Dialplan, Agent, Analytics   | app     |
| **Telekom**   | SIP Signaling, Media Service       | telekom |

## 🔧 Ortak Komutlar

```bash
# Çalışan servisleri listele
docker compose ps

# Logları görüntüle
docker compose logs -f [service_name]

# Servisleri yeniden başlat
docker compose restart [service_name]

# Sistem durumunu kontrol et
docker stats
```

## 🛡️ Güvenlik Önlemleri

1. **.env dosyalarını asla Git'e eklemeyin**
2. **Production ortamında:**
   ```bash
   # Şifre üretme
   openssl rand -base64 32 | tee .db_password
   ```
3. **Firewall ayarları:**
   ```bash
   # Data sunucusunda
   ufw allow from APP_SERVER_IP to any port 5432
   ```

## ⁉️ Sorun Giderme

**Problem:** `service depends on undefined service` hatası  
**Çözüm:** Bağımlılık servisinin profile'ını kontrol edin:
```bash
# Eksik profile'ı ekleyerek çalıştırın
docker compose --profile data --profile app up -d
```

**Problem:** Port çakışmaları  
**Çözüm:** `.env` dosyasında portları değiştirin:
```env
SIP_PORT=5070
RTP_PORT_MIN=20000-20100
```

## 🤝 Katkı
1. Repoyu fork edin
2. Yeni branch açın (`feature/new-service`)
3. Değişiklikleri test edin
4. Pull Request gönderin

## 📜 Lisans

