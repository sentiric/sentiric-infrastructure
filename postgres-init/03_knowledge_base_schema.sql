-- Adım 3: Knowledge Base Şeması (03_knowledge_base_schema.sql'den)
CREATE TABLE IF NOT EXISTS datasources (
    id SERIAL PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id),
    source_type VARCHAR(50) NOT NULL,
    source_uri TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_indexed_at TIMESTAMPTZ,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);