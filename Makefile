# Makefile - Sentiric Platform Orkestratörü v4.3 (Akıllı Servis Seçimi Destekli)

# --- Yapılandırma ---
MODE ?= local
ENV ?= development
TAG ?= latest

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- Akıllı Servis Seçimi ---
# Makefile'a verilen ekstra argümanları yakala (hedef komutlar hariç)
ARGS := $(filter-out $@,$(MAKECMDGOALS))

# --- Dinamik Komut Seçimi ---
ifeq ($(MODE), local)
	COMPOSE_FILE := docker-compose.yml
else
	COMPOSE_FILE := docker-compose.prod.yml
endif

# --- Kullanıcı Dostu Komutlar ---
local-up:
	@make up MODE=local ENV=development $(ARGS)

deploy:
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile başlatılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor..."
	@make pull MODE=deploy $(ARGS)
	@echo "--- Adım 2/2: Konteynerler başlatılıyor..."
	@make up MODE=deploy $(ARGS)

# --- Çekirdek Komutlar ---
up: generate-env
	@echo "▶️  Çalıştırılıyor: docker compose -f $(COMPOSE_FILE) up -d $(ARGS)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) up -d --remove-orphans $(ARGS)

down:
	@echo "🛑 Platform durduruluyor..."
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

pull:
	@make generate-env > /dev/null 2>&1 || true
	@echo "🔄 İmajlar çekiliyor: $(if $(ARGS),$(ARGS),all services)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) pull $(ARGS)

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

logs:
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) logs -f $(ARGS)

ps:
	@echo "📊 Konteyner durumu:"
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE) ps $(ARGS)


.PHONY: local-up deploy up down pull logs ps generate-env sync-config