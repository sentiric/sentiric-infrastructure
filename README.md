# Sentiric Infrastructure

Bu repo, Sentiric platformunun tüm altyapı kaynaklarını "Kod Olarak Altyapı" (IaC) prensibiyle yönetir.

## Mevcut Yapı: Docker Compose

Bu altyapı, `Docker Compose` kullanılarak geliştirme ve ilk üretim ortamlarını hızlıca ayağa kaldırmak için tasarlanmıştır.

### Kullanım

1.  Bu repoyu klonlayın.
2.  `.env.example` dosyasını `.env` olarak kopyalayın ve içindeki hassas bilgileri (şifreler vb.) doldurun.
3.  Tüm altyapıyı başlatmak için aşağıdaki komutu çalıştırın:
    ```bash
    docker-compose up -d
    ```
4.  Servislerin durumunu kontrol etmek için:
    ```bash
    docker-compose ps
    ```
5.  Tüm altyapıyı durdurmak için:
    ```bash
    docker-compose down
    ```