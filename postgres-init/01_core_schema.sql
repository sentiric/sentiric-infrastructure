-- Adım 1: Çekirdek Şema Tabloları (01_core_schema.sql'den)
CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id),
    user_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS announcements (
    id VARCHAR(255) PRIMARY KEY,
    description TEXT,
    audio_path VARCHAR(255) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS dialplans (
    id VARCHAR(255) PRIMARY KEY,
    description TEXT,
    action VARCHAR(255) NOT NULL, 
    action_data JSONB,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id)
);

CREATE TABLE IF NOT EXISTS inbound_routes (
    phone_number VARCHAR(255) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id),
    active_dialplan_id VARCHAR(255) REFERENCES dialplans(id),
    failsafe_dialplan_id VARCHAR(255) REFERENCES dialplans(id),
    is_maintenance_mode BOOLEAN DEFAULT FALSE
);