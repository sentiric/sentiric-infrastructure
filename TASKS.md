# 🏗️ Sentiric Infrastructure - Görev Listesi

Bu belge, `sentiric-infrastructure` reposunun geliştirme yol haritasını ve önceliklerini tanımlar.

---

### Faz 1: "Symphony" Orkestratörü (Mevcut Durum)

Bu faz, platformun tüm servislerini farklı profillerde (`dev`, `core`, `gateway`) tutarlı ve tekrarlanabilir bir şekilde yöneten temel altyapıyı oluşturmayı hedefler.

-   [x] **Profil Tabanlı `docker-compose`:** Her senaryo (`dev`, `core`, `gateway`) için bağımsız ve tam `docker-compose` dosyaları.
-   [x] **"Akıllı" `Makefile`:** Hangi profilde çalıştığını hatırlayan (`.profile.state`), sezgisel komutlar (`start`, `stop`, `logs`) sunan ve `sentiric-config`'i otomatik yöneten bir orkestratör.
-   [x] **Dinamik Yapılandırma:** `generate-env.sh` script'i ile seçilen profile göre `.env.generated` dosyasını otomatik oluşturma.
-   [x] **Dayanıklı Başlatma:** `healthcheck` ve `depends_on.condition` kullanarak servislerin doğru sırada ve sağlıklı bir şekilde başlatılmasını garanti altına alma.

---

### Faz 2: Gözlemlenebilirlik ve İzleme (Sıradaki Öncelik)

Bu faz, platformun sağlığını ve performansını proaktif olarak izlemek için gerekli araçları altyapıya eklemeyi hedefler.

-   [ ] **Görev ID: INFRA-001 - Prometheus ve Grafana Entegrasyonu**
    -   **Açıklama:** `docker-compose` dosyalarına Prometheus ve Grafana servislerini ekle. Prometheus, `sentiric-net` ağındaki tüm mikroservislerin `/metrics` endpoint'lerini otomatik olarak tarayacak şekilde yapılandırılmalıdır. Grafana için temel bir "Genel Bakış" dashboard'u (JSON olarak) oluştur.
    -   **Durum:** ⬜ Planlandı.

-   [ ] **Görev ID: INFRA-002 - Merkezi Log Yönetimi (Loki)**
    -   **Açıklama:** Tüm konteyner loglarını merkezi bir yerde toplamak, aramak ve analiz etmek için `Loki` ve `Promtail` servislerini altyapıya ekle. `docker-compose` dosyaları, tüm servislerin loglarını `loki` driver'ına gönderecek şekilde güncellenmelidir.
    -   **Durum:** ⬜ Planlandı.

-   [ ] **Görev ID: INFRA-003 - Dağıtık İzleme (Tracing) Backend**
    -   **Açıklama:** Servisler tarafından üretilen `trace` verilerini toplamak ve görselleştirmek için `Jaeger` veya `Grafana Tempo` servisini altyapıya ekle.
    -   **Durum:** ⬜ Planlandı.

---

### Faz 3: Üretim Ortamı ve Kubernetes (Uzun Vade)

-   [ ] **Görev ID: INFRA-004 - Kubernetes Manifestoları**
    -   **Açıklama:** `docker-compose` yapılandırmasını, her servis için Kubernetes `Deployment`, `Service`, `ConfigMap` ve `Secret` manifestolarına (veya Helm Chart'larına) dönüştür.
    -   **Durum:** ⬜ Planlandı.
---

### **`sentiric-config` için Yönetim Kiti**

Bu repo, projenin "gizli tarif defteridir". Hassas bilgileri ve sistemin davranışını tanımlayan kuralları içerir.
