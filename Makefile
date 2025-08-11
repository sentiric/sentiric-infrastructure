# Makefile - Sentiric Platform Orkestratörü v5.0 (En Basit ve Güvenilir)

# --- Yapılandırma ---
ENV ?= development
TAG ?= latest

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- TEMEL KOMUTLAR ---

# Tüm platformu YEREL KAYNAK KODDAN inşa eder ve çalıştırır.
# Kullanım: make up
up: generate-env
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans

# Tüm platformu HAZIR İMAJLARI ÇEKEREK çalıştırır. Önce PULL eder.
# Kullanım: make deploy
deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	@echo "--- Adım 1/2: Tüm imajlar güncelleniyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull
	@echo "--- Adım 2/2: Tüm konteynerler başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml up -d --remove-orphans

# Sadece GCP Gateway'i dağıtır.
# Kullanım: make deploy-gateway
deploy-gateway:
	@make _run_specific ENV=gcp_gateway_only SERVICE=sip-gateway

# Sadece WSL Çekirdek Servislerini dağıtır.
# Kullanım: make deploy-core
deploy-core:
	@make _run_specific ENV=wsl_core_services SERVICE="postgres rabbitmq redis qdrant user-service dialplan-service media-service sip-signaling agent-service"

# Belirli servisleri dağıtmak için dahili hedef (doğrudan kullanmayın)
_run_specific: generate-env
	@echo "🚀 '$(ENV)' ortamı için '$(SERVICE)' servis(ler)i dağıtılıyor..."
	@echo "--- Adım 1/2: İlgili imajlar güncelleniyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICE)
	@echo "--- Adım 2/2: Konteyner(ler) bağımlılıklar olmadan başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml up -d --remove-orphans --no-deps $(SERVICE)

# Diğer komutlar
down: generate-env
	@echo "🛑 Platform durduruluyor..."
	@# 'down' her iki dosyayı da kontrol ederek tüm olası konteynerleri durdurur.
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

logs: generate-env
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml logs -f $(filter-out $@,$(MAKECMDGOALS))

ps: generate-env
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml ps $(filter-out $@,$(MAKECMDGOALS))


# --- Yardımcı Komutlar (DEĞİŞİKLİK YOK) ---
generate-env: sync-config
	@echo "🔧 Dinamik yapılandırma dosyası ($(TARGET_ENV_FILE)) oluşturuluyor..."
	@if [ "$(ENV)" != "development" ]; then \
		cp "$(CONFIG_REPO_PATH)/environments/development.env" $(TARGET_ENV_FILE); \
		echo "\n# --- $(ENV).env tarafından üzerine yazılan değerler ---" >> $(TARGET_ENV_FILE); \
		cat "$(SOURCE_ENV_FILE)" >> $(TARGET_ENV_FILE); \
	else \
		cp "$(SOURCE_ENV_FILE)" $(TARGET_ENV_FILE); \
	fi
	@echo "\n# --- Makefile tarafından dinamik olarak eklendi ---" >> $(TARGET_ENV_FILE)
	@echo "PUBLIC_IP=$(DETECTED_IP)" >> $(TARGET_ENV_FILE)
	@echo "TAG=$(TAG)" >> $(TAG)

sync-config:
	@if [ ! -d "$(CONFIG_REPO_PATH)" ]; then \
		echo "🛠️ Güvenli yapılandırma reposu klonlanıyor (SSH)..."; \
		git clone git@github.com:sentiric/sentiric-config.git $(CONFIG_REPO_PATH); \
	else \
		echo "🔄 Güvenli yapılandırma reposu güncelleniyor..."; \
		(cd $(CONFIG_REPO_PATH) && git pull); \
	fi
	@if [ ! -f "$(SOURCE_ENV_FILE)" ]; then \
		echo "❌ HATA: '$(ENV)' ortamı için yapılandırma dosyası bulunamadı: $(SOURCE_ENV_FILE)"; \
		exit 1; \
	fi

.PHONY: up deploy deploy-gateway deploy-core down logs ps generate-env sync-config _run_specific