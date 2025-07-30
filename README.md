# 🚀 Sentiric Platform Orchestration Hub

Bu repo, Sentiric platformunun tüm servislerini Docker Compose kullanarak yönetmek için merkezi orkestrasyon merkezidir. Yerel geliştirmeden üretime kadar tüm dağıtım senaryolarını destekler.

## 📂 Dosya Yapısı

```plaintext
sentiric-infrastructure/
├── docker-compose.prod.yml       # Üretim için imajları çeker
├── docker-compose.override.yml   # Kaynak limitlerini belirler (CPU/RAM)
├── docker-compose.yml            # Yerel geliştirme için koddan build eder
├── deploy.sh                     # Üretim ortamı için otomatize dağıtım script'i
├── .env.local.example            # Yerel ortam için .env şablonu
└── postgres-init/                # Veritabanı başlangıç script'i
```

## 🛠️ Kurulum ve Önkoşullar

- Docker Engine (en güncel sürüm)
- **Docker Compose Plugin** (Modern `docker compose` komutu için gereklidir, eski `docker-compose` değil)
- Git
- Tüm Sentiric servis repolarının bu dizinle aynı seviyede klonlanmış olması (yerel geliştirme için).

---

## ☁️ Üretim Dağıtımı (Production Deployment) - ÖNERİLEN YÖNTEM

Üretim sunucularında, CI/CD tarafından oluşturulmuş ve test edilmiş imajları kullanarak sistemi ayağa kaldırmak için **`deploy.sh`** script'ini kullanın.

1.  **Ortamı Hazırla:**
    ```bash
    # .env.local.example dosyasını .env olarak kopyalayın
    cp .env.local.example .env
    
    # .env dosyasını açıp sunucunuzun PUBLIC_IP'si gibi değişkenleri güncelleyin
    nano .env
    ```

2.  **Dağıtım Script'ini Çalıştır:**
    ```bash
    # Script'i çalıştırılabilir yap
    chmod +x deploy.sh
    
    # Script'i çalıştırarak tüm sistemi kontrollü bir şekilde başlat
    sudo ./deploy.sh
    ```
    Bu script, sistemi temizler, en son imajları çeker ve servisleri profillere göre kademeli olarak başlatır.

---

## 🖥️ Manuel Dağıtım ve Yönetim (Gelişmiş)

### İmajları Çekme
```bash
# Tüm servislerin en son imajlarını çeker
sudo docker compose -f docker-compose.prod.yml pull
```

### Sistemi Başlatma (Profil Tabanlı)
```bash
# Sadece Veri Katmanını Başlat
sudo docker compose -f docker-compose.prod.yml -f docker-compose.override.yml --profile data up -d

# Uygulama Katmanını Ekle
sudo docker compose -f docker-compose.prod.yml -f docker-compose.override.yml --profile app up -d

# Telekom Katmanını Ekle
sudo docker compose -f docker-compose.prod.yml -f docker-compose.override.yml --profile telekom up -d
```

### Sistemi Durdurma
```bash
sudo docker compose -f docker-compose.prod.yml -f docker-compose.override.yml down
```

### Logları İzleme
```bash
# Tüm servislerin loglarını canlı olarak izle
sudo docker compose -f docker-compose.prod.yml -f docker-compose.override.yml logs -f

# Sadece belirli bir servisin loglarını izle (örn: agent-service)
sudo docker compose -f docker-compose.prod.yml -f docker-compose.override.yml logs -f agent-service
```
