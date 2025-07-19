# Sentiric Infrastructure

Bu repo, Sentiric platformunun tüm altyapı kaynaklarını "Kod Olarak Altyapı" (IaC) prensibiyle yönetir.

## 1. Sunucu İlk Kurulumu (Server Initial Setup)

Bu bölüm, boş bir Debian/Ubuntu sunucusunu Sentiric altyapısını çalıştırmaya hazır hale getirmek için gereken adımları içerir.

### Tek Komutla Kurulum

Yeni bir sunucuya bağlandıktan sonra, aşağıdaki tek komut bloğunu çalıştırarak Docker'ı kurabilir ve kullanıcı izinlerini ayarlayabilirsiniz:

```bash
# Repoyu klonla, dizine gir, script'i çalıştırılabilir yap ve çalıştır.
git clone https://github.com/sentiric/sentiric-infrastructure.git && \
cd sentiric-infrastructure && \
chmod +x setup.sh && \
./setup.sh
```
**ÖNEMLİ:** Script bittikten sonra, sunucudan **çıkış yapıp tekrar SSH ile bağlanmanız** gerekmektedir.

---

## 2. Altyapıyı Çalıştırma

Sunucu ilk kurulumu tamamlandıktan ve sunucuya yeniden bağlandıktan sonra, altyapıyı çalıştırmak için aşağıdaki adımları izleyin.

### Kullanım

1.  Eğer dizinde değilseniz, `cd sentiric-infrastructure` komutu ile dizine girin.
2.  `.env.example` dosyasını `.env` olarak kopyalayın (eğer repo'da varsa) veya sıfırdan bir `.env` dosyası oluşturun. İçindeki hassas bilgileri (şifreler vb.) kendi değerlerinizle doldurun.
3.  Tüm altyapıyı başlatmak için aşağıdaki komutu çalıştırın:
    ```bash
    docker compose up -d
    ```
4.  Servislerin durumunu kontrol etmek için:
    ```bash
    docker compose ps
    ```
5.  Tüm altyapıyı durdurmak için:
    ```bash
    docker compose down
    ```

## 3. Sistemi Sıfırlama (Reset)

Geliştirme sırasında, her şeyi temiz bir duruma getirmek veya olası build cache sorunlarını çözmek için aşağıdaki script'i kullanabilirsiniz.

**DİKKAT:** Bu script, projemizin konteynerlerine ek olarak, makinenizdeki durdurulmuş diğer tüm konteynerleri ve kullanılmayan Docker imajlarını da silecektir.

```bash
# Script'i çalıştırılabilir yap (sadece ilk seferde)
chmod +x reset.sh

# Docker ortamını sıfırla
./reset.sh
```
Bu işlemden sonra, `./start.sh` komutu ile sistemi sıfırdan, temiz bir şekilde kurabilirsiniz.

---

### **Özet ve Nihai İş Akışımız**

Artık `sentiric-infrastructure` reposunda üç güçlü aracımız var:
*   `setup.sh`: Boş bir sunucuyu Docker ile hazırlar.
*   `reset.sh`: Geliştirme ortamını tamamen sıfırlar.
*   `start.sh`: Sistemi katman katman, güvenli bir şekilde başlatır.

**Yeni Standart Geliştirme Döngümüz:**
1.  Bir sorunla karşılaştığında veya temiz bir başlangıç yapmak istediğinde: `./reset.sh`
2.  Sistemi başlatmak için: `./start.sh`
3.  Sadece logları görmek için: `docker compose logs -f [servis_adı]`
4.  Sistemi durdurmak için: `docker compose down`

