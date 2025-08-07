-- Adım 2: Çekirdek Başlangıç Verileri (02_core_data.sql'den)
INSERT INTO tenants (id, name) VALUES ('system', 'Sentiric System') ON CONFLICT (id) DO NOTHING;
INSERT INTO tenants (id, name) VALUES ('default', 'Default Tenant') ON CONFLICT (id) DO NOTHING;

INSERT INTO users (id, name, tenant_id, user_type) VALUES 
('guest_user', 'Guest Caller', 'system', 'caller'),
('905548777858', 'Azmi Sahin (Test)', 'default', 'caller') 
ON CONFLICT (id) DO NOTHING;

INSERT INTO announcements (id, description, audio_path, tenant_id) VALUES
('ANNOUNCE_SYSTEM_ERROR_TR', 'Genel sistem hatası (TR)', 'audio/tr/system_error.wav', 'system'),
('ANNOUNCE_SYSTEM_MAINTENANCE_TR', 'Sistem bakım modu (TR)', 'audio/tr/maintenance.wav', 'system'),
('ANNOUNCE_GUEST_WELCOME_TR', 'İlk kez arayan misafirler (TR)', 'audio/tr/welcome_anonymous.wav', 'system'),
('ANNOUNCE_DEFAULT_WELCOME_TR', 'Default Tenant standart karşılama (TR)', 'audio/tr/welcome.wav', 'default')
ON CONFLICT (id) DO NOTHING;

INSERT INTO dialplans (id, description, action, action_data, tenant_id) VALUES
('DP_SYSTEM_FAILSAFE', 'Tüm sistem çöktüğünde devreye giren son çare planı', 'PLAY_ANNOUNCEMENT', jsonb_build_object('announcement_id', 'ANNOUNCE_SYSTEM_ERROR_TR'), 'system'),
('DP_SYSTEM_MAINTENANCE', 'Tüm platform bakımdayken kullanılır', 'PLAY_ANNOUNCEMENT', jsonb_build_object('announcement_id', 'ANNOUNCE_SYSTEM_MAINTENANCE_TR'), 'system'),
('DP_GUEST_ENTRY', 'Kayıtlı olmayan bir arayan için ilk temas planı', 'PROCESS_GUEST_CALL', jsonb_build_object('welcome_announcement_id', 'ANNOUNCE_GUEST_WELCOME_TR'), 'system'),
('DP_TENANT_DEFAULT_WELCOME', 'Default Tenant için standart karşılama', 'START_AI_CONVERSATION', jsonb_build_object('welcome_announcement_id', 'ANNOUNCE_DEFAULT_WELCOME_TR'), 'default')
ON CONFLICT (id) DO NOTHING;

INSERT INTO inbound_routes (phone_number, tenant_id, active_dialplan_id, failsafe_dialplan_id) VALUES 
('902124548590', 'default', 'DP_TENANT_DEFAULT_WELCOME', 'DP_SYSTEM_MAINTENANCE')
ON CONFLICT (phone_number) DO NOTHING;