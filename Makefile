# Makefile - Sentiric Platform Orkestratörü v4.2 (Otomatik Güncelleme Destekli)

# --- Yapılandırma ---
# MODE: 'local' (kaynak koddan inşa eder) veya 'deploy' (hazır imajları çeker)
MODE ?= local
# ENV: Hangi .env yapılandırmasının kullanılacağını belirtir (örn: development, gcp_gateway_only)
ENV ?= development
# TAG: 'deploy' modunda hangi imaj etiketinin kullanılacağını belirtir
TAG ?= latest

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- Dinamik Komut Seçimi ---
ifeq ($(MODE), local)
	COMPOSE_FILE := docker-compose.yml
else
	COMPOSE_FILE := docker-compose.prod.yml
endif

# --- Kullanıcı Dostu Komutlar ---

# Yerel geliştirme için varsayılan komut (eskisi gibi çalışır)
# Kullanım: make local-up
local-up:
	@make up MODE=local ENV=development

# Hazır imajları kullanarak dağıtım yapmak için komut
# Bu komut artık önce imajları günceller, sonra sistemi başlatır.
# Kullanım: make deploy ENV=gcp_gateway_only sip-gateway
deploy:
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile başlatılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor..."
	@make pull MODE=deploy
	@echo "--- Adım 2/2: Konteynerler başlatılıyor..."
	@make up MODE=deploy

# Hazır imajları yerel makineye indirmek için komut
# Kullanım: make pull TAG=v1.1.0
pull:
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) pull $(filter-out $@,$(MAKECMDGOALS))

# --- Çekirdek Komutlar (Diğerleri tarafından kullanılır) ---
up: generate-env
	@# 'up' komutuna --build eklemek, prod dosyasında build bloğu varsa onu tetikler, yoksa zararsızdır.
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) up -d --build --remove-orphans $(filter-out $@,$(MAKECMDGOALS))

down:
	@echo "🛑 Platform durduruluyor..."
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

# --- Yardımcı Komutlar ---
# ... (generate-env, sync-config, logs, ps hedefleri aynı kalabilir, aşağıya kopyalıyorum) ...
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
		echo "🛠️ Güvenli yapılandırma reposu klonlanıyor..."; \
		git clone git@github.com:sentiric/sentiric-config.git $(CONFIG_REPO_PATH); \
	else \
		echo "🔄 Güvenli yapılandırma reposu güncelleniyor..."; \
		(cd $(CONFIG_REPO_PATH) && git pull); \
	fi
	@if [ ! -f "$(SOURCE_ENV_FILE)" ]; then \
		echo "❌ HATA: '$(ENV)' ortamı için yapılandırma dosyası bulunamadı: $(SOURCE_ENV_FILE)"; \
		exit 1; \
	fi

logs:
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) logs -f $(filter-out $@,$(MAKECMDGOALS))

ps:
	@echo "📊 Konteyner durumu:"
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) ps


.PHONY: local-up deploy up down pull logs ps generate-env sync-config