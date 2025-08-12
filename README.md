# 🏗️ Sentiric Infrastructure

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Orchestration](https://img.shields.io/badge/orchestration-Docker_Compose_&_Make-blue.svg)]()

Bu depo, Sentiric "İletişim İşletim Sistemi" platformunun **merkezi orkestrasyon ve dağıtım merkezidir**. "Kod Olarak Altyapı" (Infrastructure as Code - IaC) prensiplerini kullanarak, tüm Sentiric mikroservislerinin ve bağımlı altyapı bileşenlerinin tek, basit komutlarla ayağa kaldırılmasını, yönetilmesini ve yapılandırılmasını sağlar.

Bu repo, projenin **çalışan kalbidir**.

## 🎯 Temel Sorumluluklar

*   **Orkestrasyon:** `docker-compose.yml` (yerel geliştirme) ve `docker-compose.prod.yml` (dağıtım) dosyaları aracılığıyla tüm platform servislerini yönetir.
*   **Yapılandırma Yönetimi:** `sentiric-config` (private) reposundan ortam yapılandırmalarını (`.env` dosyaları) çeker ve bunları birleştirerek tüm konteynerler için tek bir `.env.generated` dosyası oluşturur.
*   **Basitleştirilmiş Arayüz:** `Makefile` kullanarak, karmaşık `docker compose` komutlarını `make up`, `make deploy`, `make logs` gibi basit, akılda kalıcı hedeflere soyutlar.
*   **Esnek Dağıtım Modelleri:** Yerel kaynak koddan inşa etme (`make up`), hazır imajları çekme (`make deploy`) ve platformun parçalarını farklı sunuculara dağıtma (hibrit dağıtım) gibi çeşitli senaryoları destekler.

## 🚀 Hızlı Başlangıç

### Önkoşullar
*   Git, Docker, Docker Compose, `make`
*   Private `sentiric-config` reposuna erişim için SSH anahtarınızın GitHub'a eklenmiş olması.

### Platformu Başlatma

1.  **Repo'yu Klonlayın:**
    ```bash
    git clone git@github.com:sentiric/sentiric-infrastructure.git
    cd sentiric-infrastructure
    ```
2.  **Platformu Başlatın:**
    *   **Geliştirme için (kaynak koddan inşa eder):**
        ```bash
        make up
        ```
    *   **Dağıtım için (hazır imajları kullanır):**
        ```bash
        make deploy
        ```
    İlk çalıştırmada `Makefile`, `sentiric-config` reposunu otomatik olarak klonlayacak ve gerekli `.env.generated` dosyasını oluşturacaktır.

## 🛠️ Komut Referansı

*   `make up`: Platformu yerel kaynak kodlarından derleyerek geliştirme modunda başlatır.
*   `make deploy`: Platformu `ghcr.io`'daki hazır imajlarla dağıtım modunda başlatır.
*   `make down`: Platformu durdurur ve **tüm verileri (veritabanı, kuyruklar vb.) siler.**
*   `make logs [SERVICES="..."]`: Belirtilen (veya tüm) servislerin loglarını izler.
*   `make ps`: Çalışan konteynerlerin durumunu listeler.
*   `make pull`: Dağıtım imajlarının en son versiyonlarını çeker.
*   `make prune`: Docker build cache'ini ve kullanılmayan imajları temizler.

Detaylı kullanım ve hibrit dağıtım senaryoları için `Makefile`'ın içindeki yorumlara ve `README.md`'nin Gelişmiş Kullanım bölümüne bakın.

## 🤝 Katkıda Bulunma

Yeni bir servis eklemek için:
1.  Servisi `docker-compose.yml` ve `docker-compose.prod.yml` dosyalarına ekleyin.
2.  Gerekli ortam değişkenlerini `sentiric-config` reposuna ekleyin.
3.  `Makefile`'daki `SERVICES` listesini (eğer varsa) güncelleyin.

---
## 🏛️ Anayasal Konum

Bu servis, [Sentiric Anayasası'nın (v11.0)](https://github.com/sentiric/sentiric-governance/blob/main/docs/blueprint/Architecture-Overview.md) **Zeka & Orkestrasyon Katmanı**'nda yer alan merkezi bir bileşendir.