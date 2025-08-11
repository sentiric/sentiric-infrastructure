# 🏗️ Sentiric Infrastructure

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Orchestration](https://img.shields.io/badge/orchestration-Docker_Compose_&_Make-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

Bu depo, Sentiric "İletişim İşletim Sistemi" platformunun **merkezi orkestrasyon ve dağıtım merkezidir**. "Kod Olarak Altyapı" (Infrastructure as Code - IaC) prensiplerini kullanarak, tüm Sentiric mikroservislerinin ve bağımlı altyapı bileşenlerinin (PostgreSQL, RabbitMQ, Redis vb.) tek bir komutla ayağa kaldırılmasını, yönetilmesini ve yapılandırılmasını sağlar.

Bu repo, projenin **çalışan kalbidir**.

## ✨ Felsefe: Basitlik, Esneklik ve Her Zaman Güncel

Altyapımız üç temel ilke üzerine kurulmuştur:
1.  **Basit Arayüz:** `Makefile` kullanarak, karmaşık `docker compose` komutlarını `make local-up` veya `make deploy` gibi basit, akılda kalıcı komutlara soyutluyoruz.
2.  **Maksimum Esneklik:** Platform, **yerel geliştirme** (kaynak koddan inşa ederek) ve **dağıtım** (hazır imajları çekerek) modları arasında kolayca geçiş yapabilir. Bu, onu her türlü senaryoya (yerel makine, bulut sunucusu, hibrit ortamlar) uyumlu hale getirir.
3.  **Her Zaman Güncel:** `deploy` modu, servisleri başlatmadan önce Docker imajlarının en güncel versiyonlarını otomatik olarak kontrol eder ve indirir (`pull`). Bu, manuel güncelleme ihtiyacını ortadan kaldırır ve sisteminizin her zaman en son, kararlı sürümle çalışmasını sağlar.

---

## 🚀 Hızlı Başlangıç: Platformu 3 Adımda Ayağa Kaldırma

### Önkoşullar
*   Git
*   Docker ve Docker Compose
*   `make` komut satırı aracı
*   Tüm `sentiric-*` servis repolarının aynı ana dizin altında klonlanmış olması (sadece `local-up` modu için gereklidir).

### Adım 1: Yapılandırmayı Klonla
Bu repo, özel ve hassas yapılandırmaları içeren `sentiric-config` reposuna bağımlıdır. `Makefile` bunu sizin için otomatik olarak yönetir. İlk çalıştırmada bu repo otomatik olarak klonlanacaktır.

### Adım 2: Ortam Değişkenlerini Ayarla
`.env.example` dosyasını kopyalayarak başlayın.
```bash
cp .env.example .env
```
Yerel geliştirme için genellikle bu dosyayı değiştirmenize gerek yoktur. `Makefile`, `PUBLIC_IP` gibi değişkenleri otomatik olarak algılayacaktır. Sadece harici servisler (Google, ElevenLabs vb.) için API anahtarlarınızı girmeniz yeterlidir.

### Adım 3: Platformu Başlat!

**Seçenek A: Yerel Geliştirme İçin (Kaynak Koddan İnşa Et)**
Eğer kodda değişiklik yapıyor ve en son halini test etmek istiyorsanız bu modu kullanın.
```bash
make local-up
```

**Seçenek B: Dağıtım / Test İçin (Hazır İmajları Kullan)**
En kararlı, CI/CD tarafından oluşturulmuş versiyonları kullanarak tüm platformu ayağa kaldırmak için bu modu kullanın. Bu komut, önce imajları güncelleyecek, sonra sistemi başlatacaktır.
```bash
make deploy
```

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
*   **`[servis_adi...]`**: Sadece belirtilen servisleri başlatmak/durdurmak/izlemek için kullanılır.

### Örnek Senaryolar

#### 1. Yerel Geliştirme (Sadece belirli servisler)
```bash
# Sadece agent-service ve bağımlılıklarını yerel koddan inşa et ve başlat
make local-up agent-service

# Sadece agent-service'in loglarını izle
make logs agent-service

# Tüm platformu durdur ve volümleri temizle
make down
```

#### 2. Uzak Sunucuya Dağıtım (Tüm Servisler)
Bu senaryo, uzak bir sunucuda tüm platformu `ghcr.io`'dan en güncel hazır imajlarla kurar.
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
    # 'gcp_gateway_only.env' yapılandırmasıyla, SADECE sip-gateway servisini deploy et.
    make deploy ENV=gcp_gateway_only sip-gateway
    ```

*   **WSL Makinesinde:**
    ```bash
    # 'wsl_core_services.env' yapılandırmasıyla, belirtilen çekirdek servisleri deploy et.
    make deploy ENV=wsl_core_services postgres rabbitmq redis qdrant sip-signaling media-service
    ```

### 4. İmajları Manuel Olarak Güncelleme
`deploy` komutu bunu otomatik yapsa da, isterseniz imajları sistemi başlatmadan önce manuel olarak güncelleyebilirsiniz:
```bash
# Belirli bir versiyonu çekmek için:
make pull TAG=v1.2.0

# Veya sadece belirli servislerin en son versiyonunu çekmek için:
make pull agent-service tts-service
```

---

Bu esnek yapı, Sentiric platformunu her türlü geliştirme ve dağıtım ihtiyacına uyacak şekilde yönetmenizi sağlar.
