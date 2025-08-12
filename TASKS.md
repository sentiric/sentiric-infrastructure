# 🏗️ Sentiric Infrastructure - Görev Listesi

Bu belge, `sentiric-infrastructure` reposunun geliştirme yol haritasını ve önceliklerini tanımlar.

---

### Faz 1: Docker Compose Tabanlı Orkestrasyon (Mevcut Durum)

Bu faz, platformun tüm servislerini tutarlı ve tekrarlanabilir bir şekilde yöneten temel altyapıyı oluşturmayı hedefler.

-   [x] **Merkezi `docker-compose.yml`:** Tüm servisler ve bağımlılıklar için tek bir orkestrasyon dosyası.
-   [x] **`Makefile` Arayüzü:** `up`, `down`, `logs` gibi karmaşık komutları basitleştiren bir arayüz.
-   [x] **Dinamik Yapılandırma Yönetimi:** `sentiric-config` reposundan `.env` dosyalarını çeken ve birleştiren `generate-env` script'i.
-   [x] **Dayanıklı Başlatma:** `healthcheck` ve `depends_on.condition` kullanarak servislerin doğru sırada ve sağlıklı bir şekilde başlatılmasını garanti altına alma.
-   [x] **Hibrit Dağıtım Desteği:** `ENV` ve `SERVICES` değişkenlerini kullanarak platformun parçalarını farklı ortamlarda dağıtma yeteneği.

---

### Faz 2: Gözlemlenebilirlik ve İzleme (Sıradaki Öncelik)

Bu faz, platformun sağlığını ve performansını proaktif olarak izlemek için gerekli araçları altyapıya eklemeyi hedefler.

-   [ ] **Görev ID: INFRA-001 - Prometheus ve Grafana Entegrasyonu**
    -   **Açıklama:** `docker-compose.yml`'e Prometheus ve Grafana servislerini ekle. Prometheus, tüm mikroservislerin `/metrics` endpoint'lerini otomatik olarak tarayacak şekilde yapılandırılmalıdır. Grafana için temel bir "Genel Bakış" dashboard'u oluştur.
    -   **Durum:** ⬜ Planlandı.

-   [ ] **Görev ID: INFRA-002 - Merkezi Log Yönetimi (ELK/Loki)**
    -   **Açıklama:** Tüm konteyner loglarını merkezi bir yerde toplamak, aramak ve analiz etmek için `Loki` ve `Promtail` (veya `Fluentd` ile ELK Stack) entegrasyonu yap.
    -   **Durum:** ⬜ Planlandı.

-   [ ] **Görev ID: INFRA-003 - Dağıtık İzleme (Distributed Tracing) Backend**
    -   **Açıklama:** Servisler tarafından üretilen `trace` verilerini toplamak ve görselleştirmek için `Jaeger` veya `Grafana Tempo` servisini altyapıya ekle.
    -   **Durum:** ⬜ Planlandı.

---

### Faz 3: Üretim Ortamı ve Kubernetes (Uzun Vade)

Bu faz, platformu yüksek erişilebilirlik ve otomatik ölçeklendirme gerektiren üretim ortamlarına taşımayı hedefler.

-   [ ] **Görev ID: INFRA-004 - Kubernetes Manifestoları**
    -   **Açıklama:** `docker-compose` yapılandırmasını, her servis için Kubernetes `Deployment`, `Service`, `ConfigMap` ve `Secret` manifestolarına (veya Helm Chart'larına) dönüştür.
    -   **Durum:** ⬜ Planlandı.