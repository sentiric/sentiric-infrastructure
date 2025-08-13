# 🏗️ Sentiric Infrastructure

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Orchestration](https://img.shields.io/badge/orchestration-Makefile_&_Docker_Compose-blue.svg)]()

Bu depo, Sentiric "İletişim İşletim Sistemi" platformunun **merkezi orkestrasyon ve dağıtım merkezidir**. "Kod Olarak Altyapı" (Infrastructure as Code - IaC) prensiplerini kullanarak, tüm Sentiric mikroservislerinin ve bağımlı altyapı bileşenlerinin tek, basit ve sezgisel komutlarla ayağa kaldırılmasını, yönetilmesini ve yapılandırılmasını sağlar.

Bu repo, projenin **çalışan kalbidir**.

## ✨ Felsefe: "Orkestra Şefi"

Altyapımız, her türlü senaryoyu minimum eforla yönetmek üzere tasarlanmıştır:
1.  **Sezgisel Arayüz:** `Makefile`, karmaşık `docker compose` komutlarını `make start`, `make stop`, `make logs` gibi basit, akılda kalıcı eylemlere soyutlar.
2.  **Profil Tabanlı Yönetim:** `PROFILE` değişkeni (`dev`, `core`, `gateway`) sayesinde, platform farklı modlarda çalışabilir:
    *   **`dev`:** Tüm servisler, yerel kaynak koddan inşa edilir.
    *   **`core`:** Gateway'ler hariç tüm servisler, hazır imajlardan çalıştırılır (WSL için ideal).
    *   **`gateway`:** Sadece gateway servisleri, hazır imajlardan çalıştırılır (Bulut sunucu için ideal).
3.  **Akıllı Durum Yönetimi:** Orkestratör, `.profile.state` dosyası sayesinde hangi profilde çalıştığını "hatırlar". `make start PROFILE=core` dedikten sonra, `make logs` veya `make stop` demek için profili tekrar belirtmenize gerek kalmaz.

## 🚀 Hızlı Başlangıç

### Önkoşullar
*   Git, Docker, Docker Compose, `make`
*   Private `sentiric-config` reposuna erişim için SSH anahtarınızın GitHub'a eklenmiş olması.
*   (Hibrit dağıtım için) `Tailscale`'in ilgili makinelerde kurulu olması.

### Platformu Başlatma (Hibrit Senaryo Örneği)

1.  **Bulut Sunucuda (GCP):**
    ```bash
    git clone ... && cd sentiric-infrastructure
    make start PROFILE=gateway
    ```
2.  **Yerel Makinede (WSL2):**
    ```bash
    git clone ... && cd sentiric-infrastructure
    make start PROFILE=core
    ```
Artık platformunuz hibrit modda çalışıyor.

## 🛠️ Komut Referansı

*   `make start [PROFILE=...]`: Platformu başlatır ve profili kaydeder.
*   `make stop`: Mevcut profilde çalışan platformu durdurur.
*   `make restart`: Platformu yeniden başlatır.
*   `make status [SERVICE=...]`: Servislerin durumunu gösterir.
*   `make logs [SERVICE=...]`: Servislerin loglarını izler.
*   `make clean`: **DİKKAT!** Tüm Docker verilerini (konteyner, imaj, volume) sıfırlar.
*   `make help`: Tüm komutları ve açıklamalarını listeler.

---
## 🏛️ Anayasal Konum
Bu repo, [Sentiric Anayasası'nın (v11.0)](https://github.com/sentiric/sentiric-governance/blob/main/docs/blueprint/Architecture-Overview.md) **Yönetim, Altyapı ve Geliştirici Ekosistemi** katmanının temel taşıdır. Platformun fiziksel olarak hayata geçirilmesinden sorumludur.
