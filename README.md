# 🏗️ Sentiric Infrastructure

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Orchestration](https://img.shields.io/badge/orchestration-Docker_Compose_&_Make-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

Bu depo, Sentiric "İletişim İşletim Sistemi" platformunun **merkezi orkestrasyon ve dağıtım merkezidir**. "Kod Olarak Altyapı" (Infrastructure as Code - IaC) prensiplerini kullanarak, tüm Sentiric mikroservislerinin ve bağımlı altyapı bileşenlerinin (PostgreSQL, RabbitMQ, Redis vb.) tek bir komutla ayağa kaldırılmasını, yönetilmesini ve yapılandırılmasını sağlar.

Bu repo, projenin **çalışan kalbidir**.

## ✨ Felsefe: Basitlik, Esneklik ve Tekrarlanabilirlik

Altyapımız üç temel ilke üzerine kurulmuştur:
1.  **Basit Arayüz:** `Makefile` kullanarak, karmaşık `docker compose` komutlarını `make local-up` veya `make deploy` gibi basit, akılda kalıcı komutlara soyutluyoruz.
2.  **Maksimum Esneklik:** Platform, **yerel geliştirme** (kaynak koddan inşa ederek) ve **dağıtım** (hazır imajları çekerek) modları arasında kolayca geçiş yapabilir. Bu, onu her türlü senaryoya (yerel makine, bulut sunucusu, hibrit ortamlar) uyumlu hale getirir.
3.  **Tekrarlanabilir Ortamlar:** `docker-compose` ve merkezi yapılandırma dosyaları sayesinde, her geliştiricinin ve her sunucunun birebir aynı ortamda çalışması garanti edilir, "benim makinemde çalışıyordu" sorunu ortadan kalkar.

---

## 🚀 Hızlı Başlangıç: Platformu 3 Adımda Ayağa Kaldırma

### Önkoşullar
*   Git
*   Docker ve Docker Compose
*   `make` komut satırı aracı
*   Tüm `sentiric-*` servis repolarının aynı ana dizin altında klonlanmış olması (sadece yerel geliştirme için).

### Adım 1: Yapılandırmayı Klonla
Bu repo, özel ve hassas yapılandırmaları içeren `sentiric-config` reposuna bağımlıdır. `Makefile` bunu sizin için otomatik olarak yönetir.

### Adım 2: Ortam Değişkenlerini Ayarla
`.env.example` dosyasını kopyalayarak başlayın.
```bash
cp .env.example .env
```
Yerel geliştirme için genellikle bu dosyayı değiştirmenize gerek yoktur. `Makefile`, `PUBLIC_IP` gibi değişkenleri otomatik olarak algılayacaktır.

### Adım 3: Platformu Başlat!
Tüm platformu yerel kaynak kodunuzdan **inşa ederek** başlatmak için:
```bash
make local-up
```
Bu komut, tüm servisleri arka planda başlatacaktır.

---

## 🛠️ Gelişmiş Kullanım ve Dağıtım Senaryoları

Bu altyapının asıl gücü, farklı dağıtım modlarını ve ortamlarını desteklemesidir.

### Komut Yapısı
Tüm `make` komutları şu yapıyı kullanır:
`make [hedef] MODE=[mod] ENV=[ortam] [servis_adi...]`

*   **`[hedef]`**: `local-up`, `deploy`, `down`, `logs`, `ps`, `pull`.
*   **`MODE`**:
    *   `local` (varsayılan): Servisleri yerel diskteki kaynak koddan inşa eder (`build:`).
    *   `deploy`: Servisleri `ghcr.io`'daki hazır Docker imajlarından çeker (`image:`).
*   **`ENV`**: `sentiric-config/environments/` altındaki hangi `.env` dosyasının kullanılacağını belirtir (örn: `development`, `gcp_gateway_only`).
*   **`[servis_adi...]`**: Sadece belirtilen servisleri başlatmak/durdurmak için kullanılır.

### Örnek Senaryolar

#### 1. Yerel Geliştirme (Tüm Servisler)
```bash
# Tüm servisleri yerel koddan inşa et ve başlat
make local-up

# Sadece agent-service'in loglarını izle
make logs agent-service

# Tüm platformu durdur ve volümleri temizle
make down
```

#### 2. Uzak Sunucuya Dağıtım (Tüm Servisler)
Bu senaryo, uzak bir sunucuda tüm platformu `ghcr.io`'dan hazır imajlarla kurar.
```bash
# 1. Sunucuda bu repoyu ve sentiric-config'i klonlayın.
# 2. .env dosyanızı oluşturup PUBLIC_IP'yi sunucunun IP'si ile değiştirin.
# 3. Aşağıdaki komutu çalıştırın:

make deploy ENV=development
```

#### 3. Hibrit Dağıtım (GCP Gateway -> WSL Çekirdek)
Bu senaryo, `sip-gateway`'i GCP'de, geri kalan servisleri ise WSL'de (Tailscale ile bağlı) çalıştırır.

*   **GCP Sunucusunda:**
    ```bash
    # 'gcp_gateway_only.env' yapılandırmasıyla, SADECE sip-gateway'i deploy et.
    make deploy ENV=gcp_gateway_only sip-gateway
    ```

*   **WSL Makinesinde:**
    ```bash
    # 'wsl_core_services.env' yapılandırmasıyla, belirtilen çekirdek servisleri deploy et.
    make deploy ENV=wsl_core_services postgres rabbitmq redis qdrant sip-signaling media-service ...
    ```

### 4. İmajları Güncelleme
Uzak bir sunucudaki imajları en son versiyonla (`:latest`) güncellemek için:
```bash
# Önce en son imajları indir
make pull

# Ardından platformu bu yeni imajlarla yeniden başlat
make deploy ENV=...
```

---

Bu esnek yapı, Sentiric platformunu her türlü geliştirme ve dağıtım ihtiyacına uyacak şekilde yönetmenizi sağlar.
