# sentiric-infrastructure/Makefile
# Makefile - Sentiric Platform Orkestratörü v5.2 (Katmanlı Konfigürasyon)

ENV ?= development
TAG ?= latest
SERVICES ?=

CONFIG_REPO_PATH := ../sentiric-config
COMMON_ENV_FILE := $(CONFIG_REPO_PATH)/environments/common.env
SPECIFIC_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- Ana Komutlar ---
up: generate-env
	@echo "▶️  Yerel geliştirme ortamı başlatılıyor: $(if $(SERVICES),$(SERVICES),all services)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans $(SERVICES)

deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICES)
	@echo "--- Adım 2/2: Konteynerler başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml up -d --remove-orphans --no-deps $(SERVICES)

down:
	@echo "🛑 Platform durduruluyor ve tüm veriler (volume'ler) siliniyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

logs:
	@echo "📜 Loglar izleniyor: $(if $(SERVICES),$(SERVICES),all services)... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml logs -f $(SERVICES)

ps:
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml ps $(SERVICES)

pull:
	@echo "🔄 İmajlar çekiliyor: $(if $(SERVICES),$(SERVICES),all services)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICES)

# --- Yardımcı Komutlar ---
generate-env: sync-config
	@echo "🔧 Dinamik yapılandırma dosyası ($(TARGET_ENV_FILE)) oluşturuluyor..."
	@# Önce ortak dosyayı kopyala
	@cp "$(COMMON_ENV_FILE)" $(TARGET_ENV_FILE)
	@# Sonra ortama özel dosyanın içeriğini ekleyerek üzerine yaz
	@echo "\n# --- $(ENV).env tarafından üzerine yazılan/eklenen değerler ---" >> $(TARGET_ENV_FILE)
	@cat "$(SPECIFIC_ENV_FILE)" >> $(TARGET_ENV_FILE)
	@# Son olarak Makefile'dan gelen dinamik değerleri ekle
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

.PHONY: up deploy down logs ps pull generate-env sync-config