-- Kullanıcılarımızı temsil edecek 'users' tablosunu oluştur.
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    tenant_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Başlangıç 'users' verilerini ekle.
INSERT INTO users (id, name, email, tenant_id) VALUES
('1001', 'Alice', 'alice@sentiric.com', 'tenant-default'),
('1002', 'Bob', 'bob@sentiric.com', 'tenant-default'),
('902124548590', 'Main IVR Account', 'ivr@sentiric.com', 'tenant-default'),
-- YENİ EKLENEN SATIR: Test kullanıcısı
('905548777858', 'Azmi Sahin', 'azmi.sahin@example.com', 'tenant-default')
ON CONFLICT (id) DO NOTHING;

\echo '✅ "users" tablosu oluşturuldu ve başlangıç verileri eklendi.'

-- Yönlendirme planlarını saklayacak 'dialplans' tablosunu oluştur.
CREATE TABLE IF NOT EXISTS dialplans (
    dialplan_id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Başlangıç 'dialplans' verilerini ekle.
INSERT INTO dialplans (dialplan_id, user_id, content, tenant_id) VALUES
('dp-internal-default', '1001', '<extension name=''internal''><condition><action application=''bridge'' data=''user/1002''/></condition></extension>', 'tenant-default'),
('dp-main-ivr', '902124548590', '<extension name=''main_ivr''><condition><action application=''answer''/><action application=''playback'' data=''sounds/welcome.wav''/></condition></extension>', 'tenant-default'),
-- YENİ EKLENEN SATIR: Test kullanıcısı için bir dialplan
('dp-azmi-default', '905548777858', '<extension name=''default_user''><condition><action application=''log'' data=''INFO User Azmi Sahin called''/></condition></extension>', 'tenant-default')
ON CONFLICT (dialplan_id) DO NOTHING;


\echo '✅ "dialplans" tablosu oluşturuldu ve başlangıç verileri eklendi.'