# Makefile - Sentiric Platform Otonom Orkestratörü v3.2 (Kendi Kendini Temizleyen)

# --- Yapılandırma ---
ENV ?= development
CONFIG_REPO_PATH ?= ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated

# --- Dinamik Keşif Mekanizması ---
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- Ana Komutlar ---
up: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [$(DETECTED_IP)] IP adresiyle başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans

down:
	@echo "🛑 Platform durduruluyor..."
	# down komutu çalışmadan önce .env.generated dosyasının var olduğundan emin olalım
	@make generate-env > /dev/null 2>&1 || true
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml down --volumes
	@# --- YENİ TEMİZLİK ADIMI ---
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

# ... (diğer hedefler aynı kalacak) ...
generate-env: sync-config
	@echo "🔧 Dinamik yapılandırma dosyası ($(TARGET_ENV_FILE)) oluşturuluyor..."
	@SOURCE_ENV_FILE="$(CONFIG_REPO_PATH)/environments/$(ENV).env"; \
	cp "$$SOURCE_ENV_FILE" $(TARGET_ENV_FILE)
	@echo "\n# --- Dinamik Olarak Eklenen Değişkenler ---" >> $(TARGET_ENV_FILE)
	@echo "PUBLIC_IP=$(DETECTED_IP)" >> $(TARGET_ENV_FILE)

logs:
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml logs -f $(filter-out $@,$(MAKECMDGOALS))

ps:
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml ps

sync-config:
	@if [ ! -d "$(CONFIG_REPO_PATH)" ]; then \
		echo "🛠️ Güvenli yapılandırma reposu klonlanıyor..."; \
		git clone git@github.com:sentiric/sentiric-config.git $(CONFIG_REPO_PATH); \
	else \
		echo "🔄 Güvenli yapılandırma reposu güncelleniyor..."; \
		(cd $(CONFIG_REPO_PATH) && git pull); \
	fi
	@if [ ! -f "$(CONFIG_REPO_PATH)/environments/$(ENV).env" ]; then \
		echo "❌ HATA: '$(ENV)' ortamı için yapılandırma dosyası bulunamadı: $(CONFIG_REPO_PATH)/environments/$(ENV).env"; \
		exit 1; \
	fi

.PHONY: up down logs ps generate-env sync-config

%:
	@: