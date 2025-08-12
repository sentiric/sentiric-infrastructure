# Makefile - Sentiric Platform Orkestratörü v5.4 (Hibrit Dağıtım Odaklı)

# --- Değişkenler ---
ENV ?= development
TAG ?= latest
SERVICES ?=

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
COMMON_ENV_FILE := $(CONFIG_REPO_PATH)/environments/common.env
SPECIFIC_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- Kompozisyon Dosyaları ---
COMPOSE_FILES := -f docker-compose.yml
PROD_COMPOSE_FILES := -f docker-compose.core.yml -f docker-compose.gateway.yml

# --- Ana Komutlar ---
up: generate-env
	@echo "▶️  Yerel geliştirme ortamı ($(ENV)) başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) up -d --build --remove-orphans $(SERVICES)

deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) $(PROD_COMPOSE_FILES) pull $(SERVICES)
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) $(PROD_COMPOSE_FILES) up -d --remove-orphans --no-deps $(SERVICES)

down:
	@echo "🛑 Platform durduruluyor ve tüm veriler (volume'ler) siliniyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) $(PROD_COMPOSE_FILES) down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

# --- Yönetim Komutları ---
logs:
	@echo "📜 Loglar izleniyor: $(if $(SERVICES),$(SERVICES),tüm servisler)... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) $(PROD_COMPOSE_FILES) logs -f $(SERVICES)

ps:
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) $(PROD_COMPOSE_FILES) ps $(SERVICES)

# --- Hibrit Dağıtım Kısayolları ---
deploy-gateway:
	@$(MAKE) ENV=gcp_gateway_only deploy_single_file FILE=docker-compose.gateway.yml

deploy-core:
	@$(MAKE) ENV=wsl_core_services deploy_single_file FILE=docker-compose.core.yml

# --- YENİ YARDIMCI HEDEF ---
deploy_single_file: generate-env
	@echo "🚀 Tek dosya ile dağıtım yapılıyor: $(FILE) (ENV: $(ENV), TAG: $(TAG))"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(FILE) pull
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(FILE) up -d --remove-orphans

# --- Yardımcı Komutlar (DEĞİŞİKLİK YOK) ---
generate-env: sync-config
	@echo "🔧 Dinamik yapılandırma dosyası ($(TARGET_ENV_FILE)) oluşturuluyor..."
	@cp "$(COMMON_ENV_FILE)" $(TARGET_ENV_FILE)
	@echo "\n# --- $(ENV).env tarafından üzerine yazılan/eklenen değerler ---" >> $(TARGET_ENV_FILE)
	@cat "$(SPECIFIC_ENV_FILE)" >> $(TARGET_ENV_FILE)
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
	@if [ ! -f "$(COMMON_ENV_FILE)" ] || [ ! -f "$(SPECIFIC_ENV_FILE)" ]; then \
		echo "❌ HATA: Gerekli yapılandırma dosyaları bulunamadı: $(COMMON_ENV_FILE) veya $(SPECIFIC_ENV_FILE)"; \
		exit 1; \
	fi

.PHONY: up deploy down logs ps deploy-gateway deploy-core deploy_single_file generate-env sync-config