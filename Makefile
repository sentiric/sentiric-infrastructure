# Makefile - Sentiric Platform Orkestratörü v4.6 (En Basit ve Güvenilir)

# --- Yapılandırma ---
MODE ?= local
ENV ?= development
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

# --- Çekirdek Komut Bloğu ---
# docker compose'a geçirilecek servis isimlerini alır.
# Örn: `make deploy sip-gateway` -> `SERVICES` = `sip-gateway`
SERVICES := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
COMPOSE_CMD = CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE)

# --- Kullanıcı Dostu Komutlar ---

# Yerel geliştirme için
# Kullanım: make local-up [servis1 servis2...]
local-up: generate-env
	@echo "▶️  Yerel geliştirme ortamı başlatılıyor: $(if $(SERVICES),$(SERVICES),all services)"
	@$(COMPOSE_CMD) up -d --build --remove-orphans $(SERVICES)

# Dağıtım için
# Kullanım: make deploy [servis1 servis2...]
deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor: $(if $(SERVICES),$(SERVICES),all services)"
	@$(COMPOSE_CMD) pull $(SERVICES)
	@echo "--- Adım 2/2: Konteynerler bağımlılıklar olmadan başlatılıyor..."
	@$(COMPOSE_CMD) up -d --remove-orphans --no-deps $(SERVICES)

# Diğer komutlar
down: generate-env
	@echo "🛑 Platform durduruluyor..."
	@$(COMPOSE_CMD) down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

logs: generate-env
	@echo "📜 Loglar izleniyor: $(if $(SERVICES),$(SERVICES),all services)... (Ctrl+C ile çık)"
	@$(COMPOSE_CMD) logs -f $(SERVICES)

ps: generate-env
	@echo "📊 Konteyner durumu:"
	@$(COMPOSE_CMD) ps $(SERVICES)

pull: generate-env
	@echo "🔄 İmajlar çekiliyor: $(if $(SERVICES),$(SERVICES),all services)"
	@$(COMPOSE_CMD) pull $(SERVICES)

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

.PHONY: local-up deploy down logs ps pull generate-env sync-config