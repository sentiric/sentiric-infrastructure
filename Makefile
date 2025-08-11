# Makefile - Sentiric Platform Orkestratörü v5.1 (Açık ve Net Komutlar)

# --- Yapılandırma ---
# Kullanım: make [hedef] ENV=[ortam] [SERVICES="servis1 servis2..."]
# Örn: make deploy ENV=gcp_gateway_only SERVICES="sip-gateway"
# Örn: make logs SERVICES="agent-service rabbitmq"

ENV ?= development
TAG ?= latest
SERVICES ?=

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')
DETECTED_IP := 34.122.40.122
# --- Komutlar ---

# Yerel geliştirme için (kaynak koddan inşa eder)
up: generate-env
	@echo "▶️  Yerel geliştirme ortamı başlatılıyor: $(if $(SERVICES),$(SERVICES),all services)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans $(SERVICES)

# Dağıtım için (hazır imajları çeker)
deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor: $(if $(SERVICES),$(SERVICES),all services)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICES)
	@echo "--- Adım 2/2: Konteynerler bağımlılıklar olmadan başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml up -d --remove-orphans --no-deps $(SERVICES)

# Sadece GCP Gateway'i dağıtır
deploy-gateway:
	@$(MAKE) deploy ENV=gcp_gateway_only SERVICES="sip-gateway"

# Sadece WSL Çekirdek Servislerini dağıtır
deploy-core:
	@$(MAKE) deploy ENV=wsl_core_services SERVICES="postgres rabbitmq redis qdrant user-service dialplan-service media-service sip-signaling agent-service llm-service tts-service"

# Sistemi durdurmak için
down: generate-env
	@echo "🛑 Platform durduruluyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

# Logları izlemek için
logs: generate-env
	@echo "📜 Loglar izleniyor: $(if $(SERVICES),$(SERVICES),all services)... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml logs -f $(SERVICES)

# Konteyner durumunu görmek için
ps: generate-env
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml ps $(SERVICES)

# İmajları çekmek için
pull: generate-env
	@echo "🔄 İmajlar çekiliyor: $(if $(SERVICES),$(SERVICES),all services)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICES)


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
	@echo "TAG=$(TAG)" >> $(TARGET_ENV_FILE)

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

.PHONY: up deploy deploy-gateway deploy-core down logs ps pull generate-env sync-config