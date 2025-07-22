# Sentiric Infrastructure: Platform Orkestrasyon Merkezi

Bu repo, Sentiric platformunun tüm servislerini bir araya getiren, hem yerel geliştirme hem de çok sunuculu üretim ortamları için ana orkestrasyon merkezidir.

## Geliştirme Ortamı Kurulumu (Tek Sunucu)

1.  Tüm Sentiric repolarını aynı dizin seviyesine klonlayın.
2.  Bu reponun içindeyken, `cp .env.local.example .env` komutuyla yerel ortam dosyanızı oluşturun.
3.  Tüm platformu başlatmak için:
    ```bash
    docker compose up --build -d
    ```
4.  Sadece belirli bir servis üzerinde çalışmak için:
    ```bash
    docker compose up --build -d agent-service postgres rabbitmq
    ```

## Üretim Ortamı Dağıtımı (Çok Sunuculu)

1.  Her sunucuya bu repoyu ve ilgili servis repolarını klonlayın.
2.  İlgili sunucuda, `.env.prod.example` şablonunu kullanarak o sunucuya özel bir `.env` dosyası oluşturun.
3.  **Telekom Sunucusunda (Sunucu 1):**
    ```bash
    docker compose -f docker-compose.yml -f compose/profiles/prod-telekom.yml --profile telekom up -d
    ```
4.  **Uygulama Sunucusunda (Sunucu 2):**
    ```bash
    docker compose -f docker-compose.yml -f compose/profiles/prod-app.yml --profile app up -d
    ```
5.  **Veri Sunucusunda (Sunucu 3):**
    ```bash
    docker compose -f docker-compose.yml -f compose/profiles/prod-data.yml --profile data up -d
    ```

* we can use Prometheus + Grafana Cloud (Ücretsiz)