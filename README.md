# 🏗️ Sentiric Infrastructure

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Orchestration](https://img.shields.io/badge/orchestration-Docker_Compose_&_Make-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

Bu depo, Sentiric "İletişim İşletim Sistemi" platformunun **merkezi orkestrasyon ve dağıtım merkezidir**. "Kod Olarak Altyapı" (Infrastructure as Code - IaC) prensiplerini kullanarak, tüm Sentiric mikroservislerinin ve bağımlı altyapı bileşenlerinin tek, basit komutlarla ayağa kaldırılmasını, yönetilmesini ve yapılandırılmasını sağlar.

Bu repo, projenin **çalışan kalbidir**.

## ✨ Felsefe: Basit Arayüz, Maksimum Esneklik

Altyapımız, her türlü senaryoyu desteklemek üzere tasarlanmıştır:
1.  **Basit Arayüz:** `Makefile` kullanarak, karmaşık `docker compose` komutlarını `make up`, `make deploy`, `make logs` gibi basit, akılda kalıcı hedeflere soyutluyoruz.
2.  **Maksimum Esneklik:** Platform, farklı modlarda çalışabilir:
    *   **Yerel Geliştirme (`make up`):** Kaynak koddan inşa ederek en son değişikliklerle çalışmanızı sağlar.
    *   **Dağıtım (`make deploy`):** `ghcr.io`'daki hazır, stabil Docker imajlarını kullanarak platformu kurar.
3.  **Hibrit ve Dağıtık Kurulum:** `make deploy-gateway` ve `make deploy-core` gibi özel hedefler sayesinde, platformun parçalarını farklı sunuculara (örn: bir parça bulutta, bir parça yerelde) kolayca dağıtabilirsiniz.
4.  **Her Zaman Güncel:** `deploy` modu, servisleri başlatmadan önce Docker imajlarının en güncel versiyonlarını otomatik olarak kontrol eder ve indirir (`pull`).

---

## 🚀 Hızlı Başlangıç: Platformu 3 Adımda Ayağa Kaldırma

### Önkoşullar
*   Git
*   Docker ve Docker Compose
*   `make` komut satırı aracı
*   Private `sentiric-config` reposuna erişim için SSH anahtarınızın GitHub'a eklenmiş olması.
*   (Sadece `make up` modu için) Tüm `sentiric-*` servis repolarının aynı ana dizin altında klonlanmış olması.

### Adım 1: Altyapı ve Yapılandırmayı Hazırla
Bu komut, hem altyapı reposunu (`sentiric-infrastructure`) hem de özel yapılandırma reposunu (`sentiric-config`) klonlar.
```bash
git clone git@github.com:sentiric/sentiric-infrastructure.git
cd sentiric-infrastructure
# Makefile, config reposunu ilk çalıştırmada otomatik olarak klonlayacaktır.
```

### Adım 2: Ortam Değişkenlerini Ayarla
`.env.example` dosyasını kopyalayarak başlayın.
```bash
cp .env.example .env
```
Yerel geliştirme için genellikle sadece harici servisler (Google, ElevenLabs vb.) için API anahtarlarınızı girmeniz yeterlidir.

### Adım 3: Platformu Başlat!

**Seçenek A: Yerel Geliştirme İçin (Kaynak Koddan İnşa Et)**
Eğer kodda değişiklik yapıyor ve en son halini test etmek istiyorsanız bu modu kullanın.
```bash
# Tüm platformu başlat
make up

# Veya sadece belirli servisleri ve bağımlılıklarını başlat
# make up agent-service
```

**Seçenek B: Dağıtım / Test İçin (Hazır İmajları Kullan)**
En kararlı, CI/CD tarafından oluşturulmuş versiyonları kullanarak tüm platformu ayağa kaldırmak için bu modu kullanın.
```bash
make deploy
```
---

## 🛠️ Komut Referansı ve Gelişmiş Kullanım

`Makefile`'ımız, farklı senaryoları yönetmek için değişkenleri kullanır.

### Komut Yapısı
`make [hedef] [DEĞİŞKEN=değer] [SERVICES="servis1 servis2..."]`

*   **`[hedef]`**: `up`, `deploy`, `down`, `logs`, `ps`, `pull`, `deploy-gateway`, `deploy-core`.
*   **`ENV`**: `sentiric-config/environments/` altındaki hangi `.env` dosyasının kullanılacağını belirtir. **Varsayılan: `development`**. Bu, farklı dağıtım senaryolarını yönetmek için en önemli değişkendir.
*   **`SERVICES`**: Komutun sadece belirtilen servislere uygulanmasını sağlar. Boş bırakılırsa tüm servisler hedeflenir.

### Yönetim ve İzleme Komutları

*   **Sistemi Durdur:**
    ```bash
    # 'development' ortamında çalışan sistemi durdurur
    make down

    # 'wsl_core_services' ortamında çalışan sistemi durdurur
    make down ENV=wsl_core_services
    ```

*   **Konteyner Durumunu Gör:**
    ```bash
    # 'development' ortamındaki servislerin durumunu gösterir
    make ps

    # 'wsl_core_services' ortamındaki servislerin durumunu gösterir
    make ps ENV=wsl_core_services
    ```

*   **Logları İzle:**
    ```bash
    # 'development' ortamındaki tüm servislerin loglarını izler
    make logs

    # 'wsl_core_services' ortamındaki tüm servislerin loglarını izler
    make logs ENV=wsl_core_services

    # Sadece belirli servislerin loglarını izlemek için:
    make logs SERVICES="agent-service sip-signaling"
    ```

---

## 🌐 Hibrit Dağıtım Senaryosu: GCP Gateway + WSL Çekirdek

Bu senaryo, platformun `sip-gateway`'ini genel IP'ye sahip bir bulut sunucusunda (GCP), geri kalan tüm çekirdek servisleri ise yerel makinenizde (WSL) çalıştırmanıza olanak tanır.

**Önkoşullar:**
*   Hem GCP sunucusunda hem de WSL makinenizde **Tailscale**'in kurulu ve aynı ağa bağlı olması.
*   `sentiric-config/environments/` altındaki `gcp_gateway_only.env` ve `wsl_core_services.env` dosyalarının doğru IP adresleriyle yapılandırılmış olması.

### Adım 1: GCP Sunucusunda Gateway'i Başlatın
```bash
# GCP sunucusunda, sentiric-infrastructure dizinindeyken:
make deploy-gateway
```
Bu komut, `ENV=gcp_gateway_only` ve `SERVICES="sip-gateway"` değişkenlerini otomatik olarak ayarlayarak **sadece** `sip-gateway` servisini başlatır.

### Adım 2: WSL Makinesinde Çekirdek Servisleri Başlatın
```bash
# WSL makinenizde, sentiric-infrastructure dizinindeyken:
make deploy-core
```
Bu komut, `ENV=wsl_core_services` ve ilgili servis listesini otomatik olarak ayarlayarak `sip-gateway` **hariç** diğer tüm temel servisleri başlatır.

### Adım 3: Hibrit Sistemi İzleme
*   **GCP'de Gateway Logları:**
    ```bash
    make logs ENV=gcp_gateway_only
    ```
*   **WSL'de Çekirdek Logları:**
    ```bash
    make logs ENV=wsl_core_services
    ```
Bu esnek yapı, Sentiric platformunu her türlü geliştirme ve dağıtım ihtiyacına uyacak şekilde yönetmenizi sağlar.
