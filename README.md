# 🏗️ Sentiric Infrastructure

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Orchestration](https://img.shields.io/badge/orchestration-Docker_Compose_&_Make-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

Bu depo, Sentiric "İletişim İşletim Sistemi" platformunun **merkezi orkestrasyon ve dağıtım merkezidir**. "Kod Olarak Altyapı" (Infrastructure as Code - IaC) prensiplerini kullanarak, tüm Sentiric mikroservislerinin ve bağımlı altyapı bileşenlerinin tek, basit komutlarla ayağa kaldırılmasını, yönetilmesini ve yapılandırılmasını sağlar.

Bu repo, projenin **çalışan kalbidir**.

## ✨ Felsefe: Basit Arayüz, Maksimum Esneklik

Altyapımız, her türlü senaryoyu desteklemek üzere tasarlanmıştır:
1.  **Basit Arayüz:** `Makefile` kullanarak, karmaşık `docker compose` komutlarını `make up`, `make deploy`, `make deploy-gateway` gibi basit, akılda kalıcı hedeflere soyutluyoruz.
2.  **Maksimum Esneklik:** Platform, farklı modlarda çalışabilir:
    *   **Yerel Geliştirme (`make up`):** Kaynak koddan inşa ederek en son değişikliklerle çalışmanızı sağlar.
    *   **Dağıtım (`make deploy`):** `ghcr.io`'daki hazır, stabil Docker imajlarını kullanarak platformu kurar.
3.  **Hibrit ve Dağıtık Kurulum:** `make deploy-gateway` ve `make deploy-core` gibi özel hedefler sayesinde, platformun parçalarını farklı sunuculara (örn: bir parça bulutta, bir parça yerelde) kolayca dağıtabilirsiniz.

---

## 🚀 Hızlı Başlangıç: Platformu 3 Adımda Ayağa Kaldırma

### Önkoşullar
*   Git
*   Docker ve Docker Compose
*   `make` komut satırı aracı
*   Tüm `sentiric-*` servis repolarının aynı ana dizin altında klonlanmış olması (`make up` modu için gereklidir).
*   Private `sentiric-config` reposuna erişim için SSH anahtarınızın GitHub'a eklenmiş olması.

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
make up
# Veya sadece belirli servisleri başlatmak için:
# make up agent-service postgres rabbitmq
```

**Seçenek B: Dağıtım / Test İçin (Hazır İmajları Kullan)**
En kararlı, CI/CD tarafından oluşturulmuş versiyonları kullanarak tüm platformu ayağa kaldırmak için bu modu kullanın. Bu komut, önce imajları güncelleyecek, sonra sistemi başlatacaktır.
```bash
make deploy
```

---

## 🌐 Hibrit Dağıtım Senaryosu: GCP Gateway + WSL Çekirdek

Bu senaryo, platformun `sip-gateway`'ini genel IP'ye sahip bir bulut sunucusunda (GCP), geri kalan tüm çekirdek servisleri ise yerel makinenizde (WSL) çalıştırmanıza olanak tanır. İki makine arasındaki iletişim **Tailscale** gibi bir özel ağ çözümü ile sağlanır.

**Önkoşullar:**
*   Hem GCP sunucusunda hem de WSL makinenizde Tailscale'in kurulu ve aynı ağa bağlı olması.
*   `sentiric-config/environments/` altında `gcp_gateway_only.env` ve `wsl_core_services.env` dosyalarının doğru IP adresleriyle yapılandırılmış olması.

### Adım 1: GCP Sunucusunda Gateway'i Başlatın
```bash
# GCP sunucusunda, sentiric-infrastructure dizinindeyken:
make deploy-gateway
```
Bu komut, `gcp_gateway_only.env` yapılandırmasını kullanarak **sadece** `sip-gateway` servisini başlatır.

### Adım 2: WSL Makinesinde Çekirdek Servisleri Başlatın
```bash
# WSL makinenizde, sentiric-infrastructure dizinindeyken:
make deploy-core
```
Bu komut, `wsl_core_services.env` yapılandırmasını kullanarak `sip-gateway` **hariç** diğer tüm temel servisleri başlatır.

Artık sisteminiz hibrit modda çalışmaya hazırdır!

---

## 🛠️ Diğer `make` Komutları

*   **Sistemi Durdur:** `make down`
*   **Logları İzle:** `make logs` veya `make logs agent-service sip-signaling`
*   **Konteyner Durumunu Gör:** `make ps`
*   **İmajları Manuel Güncelle:** `make pull` veya `make pull agent-service`
