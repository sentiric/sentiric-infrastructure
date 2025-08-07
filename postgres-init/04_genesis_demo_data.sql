-- "Genesis Demo" için Tenant'lar, Tablolar ve Veri Kaynakları
-- Bu script, Sentiric platformunun farklı dikey sektörlerdeki yeteneklerini sergilemek
-- için gerekli başlangıç verilerini oluşturur.
-- '   -> Adım 4/4: Genesis Demo verileri ve tabloları ekleniyor...'

-- =================================================================
-- 1. ADIM: Demo Tenant'larını Oluştur
-- Her bir dikey kullanım senaryosu için ayrı bir kiracı (tenant) tanımlıyoruz.
-- =================================================================
INSERT INTO tenants (id, name) VALUES
('sentiric_health', 'Sentiric Health Demo'),
('sentiric_travel', 'Sentiric Travel Demo'),
('sentiric_eats', 'Sentiric Eats Demo'),
('sentiric_events', 'Sentiric Events Demo'),
('sentiric_support', 'Sentiric Platform Support')
ON CONFLICT (id) DO NOTHING;

-- =================================================================
-- 2. ADIM: Tenant'lara Özel Veritabanı Tablolarını Oluştur ve Doldur
-- Bu tablolar, "postgres" tipi veri kaynakları tarafından okunacaktır.
-- =================================================================

-- Sentiric Health için Hizmetler Tablosu
CREATE TABLE IF NOT EXISTS health_services (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2),
    requires_prepayment BOOLEAN DEFAULT FALSE
);
-- Mevcut verileri temizleyip yeniden ekleyerek tekrar çalıştırılabilirliği sağlıyoruz
TRUNCATE TABLE health_services RESTART IDENTITY; 
INSERT INTO health_services (service_name, description, price, requires_prepayment) VALUES
('Genel Muayene', 'Uzman doktor tarafından genel sağlık kontrolü ve ilk teşhis.', 500.00, FALSE),
('VIP Check-up Paketi', 'Kapsamlı sağlık taraması ve laboratuvar testleri.', 2500.00, TRUE),
('Diş Beyazlatma', 'Lazer teknolojisi ile profesyonel diş beyazlatma işlemi.', 1500.00, TRUE),
('Psikolojik Danışmanlık', 'Lisanslı psikolog ile 50 dakikalık bireysel terapi seansı.', 750.00, FALSE);

-- Sentiric Events için Etkinlikler Tablosu
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(255) NOT NULL,
    venue VARCHAR(255),
    event_date DATE,
    ticket_price NUMERIC(10, 2)
);
TRUNCATE TABLE events RESTART IDENTITY;
INSERT INTO events (event_name, venue, event_date, ticket_price) VALUES
('Rock Konseri', 'Zorlu PSM', '2025-09-15', 750.00),
('Caz Gecesi', 'Nardis Jazz Club', '2025-09-22', 450.00),
('Stand-up Gösterisi', 'BKM Mutfak', '2025-10-01', 300.00);


-- =================================================================
-- 3. ADIM: Knowledge Service için Veri Kaynaklarını Tanımla
-- Her tenant'ın hangi verileri okuyacağını burada belirliyoruz.
-- URL'ler, sentiric-assets reposunun GitHub Pages CDN adresini kullanır.
-- =================================================================
TRUNCATE TABLE datasources RESTART IDENTITY;
INSERT INTO datasources (tenant_id, source_type, source_uri) VALUES
('sentiric_health', 'postgres', 'health_services'),
('sentiric_health', 'web', 'https://sentiric.github.io/sentiric-assets/knowledge_base/sentiric_health/emergency_protocol.md'),
('sentiric_health', 'web', 'https://sentiric.github.io/sentiric-assets/knowledge_base/sentiric_health/services_faq.md'),
('sentiric_travel', 'web', 'https://sentiric.github.io/sentiric-assets/knowledge_base/sentiric_travel/hotel_info.md'),
('sentiric_eats', 'web', 'https://sentiric.github.io/sentiric-assets/knowledge_base/sentiric_eats/menu.txt'),
('sentiric_support', 'web', 'https://fastapi.tiangolo.com/'),
('sentiric_support', 'web', 'https://sentiric.github.io/sentiric-assets/knowledge_base/sentiric_support/complaint_policy.md'),
('sentiric_events', 'postgres', 'events'),
('sentiric_events', 'web', 'https://sentiric.github.io/sentiric-assets/knowledge_base/sentiric_events/faq.md');