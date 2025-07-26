-- Bu script, Docker Compose tarafından PostgreSQL konteyneri ilk kez başlatıldığında
-- otomatik olarak /docker-entrypoint-initdb.d/ dizininden çalıştırılır.

-- 'sentiric_db' veritabanı, POSTGRES_DB ortam değişkeni ile Docker tarafından
-- zaten oluşturulmuş olacaktır. Bu yüzden direkt o veritabanına bağlanmış oluruz.

-- Kullanıcılarımızı temsil edecek 'users' tablosunu oluştur.
-- IF NOT EXISTS ifadesi, script'in tekrar çalışması durumunda hata vermesini engeller.
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY, -- Telefon numarası veya dahili ID gibi benzersiz bir anahtar
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    tenant_id VARCHAR(255) NOT NULL, -- Hangi müşteriye ait olduğu
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Test ve geliştirme için başlangıç verilerini ekle.
-- ON CONFLICT (id) DO NOTHING; ifadesi, script tekrar çalışırsa
-- aynı veriyi eklemeye çalışıp hata vermesini engeller.
INSERT INTO users (id, name, email, tenant_id) VALUES
('1001', 'Alice', 'alice@sentiric.com', 'tenant-default'),
('1002', 'Bob', 'bob@sentiric.com', 'tenant-default'),
('902124548590', 'Main IVR Account', 'ivr@sentiric.com', 'tenant-default')
ON CONFLICT (id) DO NOTHING;

-- Loglama için, işlemin tamamlandığını belirten bir mesaj.
\echo '✅ "users" tablosu oluşturuldu ve başlangıç verileri eklendi.'