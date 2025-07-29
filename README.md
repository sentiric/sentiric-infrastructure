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


## 🖥️ Yerel Geliştirme (Local Development)

Yerel makinenizde, kodda yaptığınız değişiklikleri anında test etmek için **`docker-compose.yml`** dosyasını kullanın. Bu dosya, servisleri yerel kaynak kodunuzdan inşa eder (`build`).

1.  **Ortamı Hazırla:**
    ```bash
    cp .env.local.example .env
    # .env dosyasını kendi lokal ayarlarınıza göre düzenleyin.
    ```
2.  **Tüm Sistemi İnşa Et ve Başlat:**
    ```bash
    # Bu komut, tüm servisleri yerel koddan build eder ve başlatır.
    docker-compose -f docker-compose.yml --profile default  down
    docker-compose -f docker-compose.yml --profile default  up --build -d
    docker-compose -f docker-compose.yml -f docker-compose.override.yml up  
    ```

## ☁️ Üretim Dağıtımı (Production Deployment)

Üretim sunucularında, CI/CD tarafından oluşturulmuş ve test edilmiş imajları doğrudan GitHub Container Registry'den (`ghcr.io`) çekmek için **`docker-compose.prod.yml`** dosyasını kullanın. Bu, `build` işlemi yapmaz.

1.  **Ortamı Hazırla:**
    *   Üretim sunucusuna özel bir `.env` dosyası oluşturun (`.env.prod.example`'dan kopyalayarak).
    *   `PUBLIC_IP` gibi değişkenleri sunucunun gerçek IP adresiyle güncelleyin.

2.  **En Son İmajları Çek:**
    ```bash
    # Opsiyonel: TAG=v1.2.3 gibi belirli bir versiyonu belirtebilirsiniz.
    # export TAG=v1.2.3
    docker-compose -f docker-compose.prod.yml pull
    ```

3.  **Sistemi Başlat:**
    ```bash
    # Sadece ilgili sunucunun profilini başlatmak için:
    # docker-compose -f docker-compose.prod.yml --profile data up -d
    # docker-compose -f docker-compose.prod.yml --profile app up -d
    # docker-compose -f docker-compose.prod.yml --profile telekom up -d

    # Veya tek bir sunucuda tüm sistemi başlatmak için:
    docker-compose -f docker-compose.prod.yml --profile default up -d
    ```
## 🌐 Servis Dağılımı

| Sunucu Tipi   | Servisler                          | Profile |
|---------------|------------------------------------|---------|
| **Data**      | PostgreSQL, RabbitMQ, Redis, MongoDB | data    |
| **App**       | User, Dialplan, Agent, Analytics   | app     |
| **Telekom**   | SIP Signaling, Media Service       | telekom |
