-- Bu dosya, Docker tarafından otomatik olarak çalıştırılan ana giriş noktasıdır.
-- Diğer SQL dosyalarını belirli bir sırada çalıştırır.
\echo '🚀 Sentiric Veritabanı Kurulumu Başlatılıyor...'
\i /docker-entrypoint-initdb.d/01_core_schema.sql
\i /docker-entrypoint-initdb.d/02_core_data.sql
\i /docker-entrypoint-initdb.d/03_knowledge_base_schema.sql
\i /docker-entrypoint-initdb.d/04_genesis_demo_data.sql
\echo '✅ Sentiric Veritabanı Kurulumu Tamamlandı.'