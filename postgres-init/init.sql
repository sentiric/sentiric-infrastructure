-- DOSYA: sentiric-infrastructure/postgres-init/init.sql (GENESIS BLOCK v1.1 - NİHAİ VERSİYON)

-- =================================================================
-- Tablo 1: Kiracılar (Tenants) - Platformumuzun Müşterileri
-- =================================================================
CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO tenants (id, name) VALUES ('system_tenant', 'Sentiric System') ON CONFLICT (id) DO NOTHING;
INSERT INTO tenants (id, name) VALUES ('default_tenant', 'Default Tenant') ON CONFLICT (id) DO NOTHING;
\echo '✅ Tablo 1/5: "tenants" oluşturuldu.'

-- =================================================================
-- Tablo 2: Kullanıcılar (Users) - Arayanlar, Agent''lar, Yöneticiler
-- =================================================================
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id),
    user_type VARCHAR(50) NOT NULL, -- 'caller', 'agent', 'admin'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (id, name, tenant_id, user_type) VALUES 
('guest_user', 'Guest Caller', 'system_tenant', 'caller'),
('905548777858', 'Azmi Sahin (Test)', 'default_tenant', 'caller') 
ON CONFLICT (id) DO NOTHING;
\echo '✅ Tablo 2/5: "users" oluşturuldu.'

-- =================================================================
-- Tablo 3: Anonslar (Announcements) - Dinamik Ses Dosyaları
-- =================================================================
CREATE TABLE IF NOT EXISTS announcements (
    id VARCHAR(255) PRIMARY KEY,
    description TEXT,
    -- DÜZELTME: Dosya yolları artık dil klasörünü içeriyor.
    audio_path VARCHAR(255) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id)
);
INSERT INTO announcements (id, description, audio_path, tenant_id) VALUES
('ANNOUNCE_SYSTEM_ERROR_TR', 'Genel sistem hatası (TR)', 'audio/tr/system_error.wav', 'system_tenant'),
('ANNOUNCE_SYSTEM_MAINTENANCE_TR', 'Sistem bakım modu (TR)', 'audio/tr/maintenance.wav', 'system_tenant'),
('ANNOUNCE_GUEST_WELCOME_TR', 'İlk kez arayan misafirler (TR)', 'audio/tr/welcome_anonymous.wav', 'system_tenant'),
('ANNOUNCE_DEFAULT_WELCOME_TR', 'Default Tenant standart karşılama (TR)', 'audio/tr/welcome.wav', 'default_tenant')
ON CONFLICT (id) DO NOTHING;
\echo '✅ Tablo 3/5: "announcements" oluşturuldu.'

-- =================================================================
-- Tablo 4: Yönlendirme Planları (Dialplans) - Eylem Merkezi
-- =================================================================
CREATE TABLE IF NOT EXISTS dialplans (
    id VARCHAR(255) PRIMARY KEY,
    description TEXT,
    action VARCHAR(255) NOT NULL, 
    action_data JSONB,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id)
);
-- DÜZELTME: action_data içindeki anons ID'leri de dil kodunu içerecek şekilde güncellendi.
INSERT INTO dialplans (id, description, action, action_data, tenant_id) VALUES
('DP_SYSTEM_FAILSAFE', 'Tüm sistem çöktüğünde devreye giren son çare planı', 'PLAY_ANNOUNCEMENT', jsonb_build_object('announcement_id', 'ANNOUNCE_SYSTEM_ERROR_TR'), 'system_tenant'),
('DP_SYSTEM_MAINTENANCE', 'Tüm platform bakımdayken kullanılır', 'PLAY_ANNOUNCEMENT', jsonb_build_object('announcement_id', 'ANNOUNCE_SYSTEM_MAINTENANCE_TR'), 'system_tenant'),
('DP_GUEST_ENTRY', 'Kayıtlı olmayan bir arayan için ilk temas planı', 'PROCESS_GUEST_CALL', jsonb_build_object('welcome_announcement_id', 'ANNOUNCE_GUEST_WELCOME_TR'), 'system_tenant'),
('DP_TENANT_DEFAULT_WELCOME', 'Default Tenant için standart karşılama', 'START_AI_CONVERSATION', jsonb_build_object('welcome_announcement_id', 'ANNOUNCE_DEFAULT_WELCOME_TR'), 'default_tenant')
ON CONFLICT (id) DO NOTHING;
\echo '✅ Tablo 4/5: "dialplans" oluşturuldu.'

-- =================================================================
-- Tablo 5: Gelen Yönlendirmeler (Inbound Routes) - Numaraların Atanması
-- =================================================================
CREATE TABLE IF NOT EXISTS inbound_routes (
    phone_number VARCHAR(255) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id),
    active_dialplan_id VARCHAR(255) REFERENCES dialplans(id),
    failsafe_dialplan_id VARCHAR(255) REFERENCES dialplans(id),
    is_maintenance_mode BOOLEAN DEFAULT FALSE
);
INSERT INTO inbound_routes (phone_number, tenant_id, active_dialplan_id, failsafe_dialplan_id) VALUES 
('902124548590', 'default_tenant', 'DP_TENANT_DEFAULT_WELCOME', 'DP_SYSTEM_MAINTENANCE')
ON CONFLICT (phone_number) DO NOTHING;
\echo '✅ Tablo 5/5: "inbound_routes" oluşturuldu.'
\echo '🚀 Veritabanı "Genesis Bloğu" v1.1 başarıyla oluşturuldu.'


-- =================================================================
-- KNOWLEDGE SERVICE İÇİN VERİ KAYNAKLARI
-- =================================================================

-- Her tenant'ın bilgi kaynaklarını tanımlayan tablo
CREATE TABLE datasources (
    id SERIAL PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    source_type VARCHAR(50) NOT NULL, -- 'file', 'web', 'postgres'
    source_uri TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_indexed_at TIMESTAMPTZ
);

-- Örnek tenant'lar için veri kaynakları
INSERT INTO datasources (tenant_id, source_type, source_uri) VALUES
('acme_corp', 'file', 'acme_specs.md'),
('acme_corp', 'web', 'https://requests.readthedocs.io/en/latest/'),
('beta_health', 'file', 'beta_faq.txt'),
('beta_health', 'postgres', 'medical_services');


-- Beta Health tenant'ı için örnek bir tıbbi hizmetler tablosu
CREATE TABLE medical_services (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2)
);

-- Bu tabloyu örnek verilerle dolduralım
INSERT INTO medical_services (service_name, description, price) VALUES
('Genel Muayene', 'Uzman doktor tarafından genel sağlık kontrolü ve ilk teşhis.', 500.00),
('Diş Beyazlatma', 'Lazer teknolojisi ile profesyonel diş beyazlatma işlemi.', 1500.00),
('Psikolojik Danışmanlık', 'Lisanslı psikolog ile 50 dakikalık bireysel terapi seansı.', 750.00),
('Acil Servis Başvurusu', '7/24 acil durumlar için müdahale hizmeti.', 800.00);


--

-- =================================================================
-- SENTIRIC GENESIS DEMO İÇİN VERİ KAYNAKLARI
-- =================================================================

INSERT INTO datasources (tenant_id, source_type, source_uri) VALUES
-- Tenant 1: Beta Health (Hastane Randevu & Acil Durum)
('beta_health', 'postgres', 'medical_services'), -- DB'den hizmetleri öğrenir
('beta_health', 'file', 'beta_emergency_protocol.md'), -- Dosyadan acil durum protokolünü öğrenir

-- Tenant 2: Sunshine Hotel (Otel Rezervasyonu)
('sunshine_hotel', 'file', 'sunshine_hotel_info.md'), -- Dosyadan otel bilgilerini öğrenir

-- Tenant 3: Napoli Pizza (Paket Servis)
('napoli_pizza', 'file', 'napoli_pizza_menu.txt'), -- Dosyadan menüyü öğrenir

-- Tenant 4: Sentiric Destek (Sanal Santral & Şikayet Yönetimi)
('sentiric_support', 'web', 'https://fastapi.tiangolo.com/'), -- CANLI WEB SİTESİ: FastAPI dokümanları
('sentiric_support', 'file', 'sentiric_complaint_policy.txt'), -- Dosyadan şikayet politikasını öğrenir

-- Tenant 5: Biletix Demo (Etkinlik ve Bilet Bilgisi)
('biletix_demo', 'postgres', 'events'); -- DB'den etkinlikleri öğrenir


-- Biletix Demo için yeni bir tablo ve veriler
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(255) NOT NULL,
    venue VARCHAR(255),
    event_date DATE,
    ticket_price NUMERIC(10, 2)
);

INSERT INTO events (event_name, venue, event_date, ticket_price) VALUES
('Rock Konseri', 'Zorlu PSM', '2025-09-15', 750.00),
('Caz Gecesi', 'Nardis Jazz Club', '2025-09-22', 450.00),
('Stand-up Gösterisi', 'BKM Mutfak', '2025-10-01', 300.00);

-- "Genesis Demo" için yeni bir tenant
INSERT INTO datasources (tenant_id, source_type, source_uri) VALUES
('antalya_concierge', 'google_travel', 'Antalya');