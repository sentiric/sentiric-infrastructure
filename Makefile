# Makefile - Sentiric Platform Orkestratörü v4.8 (Güvenilir Hibrit Dağıtım)

# --- Yapılandırma ---
# Örn: make deploy ENV=gcp_gateway_only sip-gateway
# Örn: make local-up agent-service
# Örn: make logs sip-gateway sip-signaling
#
# MODE: 'local' (kaynak koddan inşa eder) veya 'deploy' (hazır imajları çeker)
#       Bu değişken, hedefler tarafından otomatik olarak ayarlanır.
# ENV: Hangi .env yapılandırmasının kullanılacağını belirtir (örn: development, gcp_gateway_only)
ENV ?= development
# TAG: 'deploy' modunda hangi imaj etiketinin kullanılacağını belirtir
TAG ?= latest

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')

# --- Akıllı Servis Seçimi ---
# make komutuna verilen hedef dışındaki tüm argümanları yakalar.
# Örn: `make deploy sip-gateway` -> `SERVICES` = `sip-gateway`
SERVICES := $(filter-out $(firstword $(MAKECMDGOALS)),$(MAKECMDGOALS))

# --- Kullanıcı Dostu Komutlar ---

# Yerel geliştirme için (kaynak koddan inşa eder)
# Kullanım: make local-up [servis1...]
local-up:
	@$(MAKE) --no-print-directory _run_compose MODE=local UP_ARGS="up -d --build --remove-orphans"

# Dağıtım için (hazır imajları çeker ve bağımlılıkları başlatmaz)
# Kullanım: make deploy ENV=... [servis1...]
deploy:
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor: $(if $(SERVICES),$(SERVICES),all services)"
	@$(MAKE) --no-print-directory _run_compose MODE=deploy UP_ARGS="pull"
	@echo "--- Adım 2/2: Konteynerler bağımlılıklar olmadan başlatılıyor..."
	@$(MAKE) --no-print-directory _run_compose MODE=deploy UP_ARGS="up -d --remove-orphans --no-deps"

# Diğer komutlar
down:
	@echo "🛑 Platform durduruluyor..."
	@$(MAKE) --no-print-directory _run_compose MODE=local UP_ARGS="down --volumes"
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

logs:
	@echo "📜 Loglar izleniyor: $(if $(SERVICES),$(SERVICES),all services)... (Ctrl+C ile çık)"
	@$(MAKE) --no-print-directory _run_compose MODE=local UP_ARGS="logs -f"

ps:
	@echo "📊 Konteyner durumu:"
	@$(MAKE) --no-print-directory _run_compose MODE=local UP_ARGS="ps"

pull:
	@echo "🔄 İmajlar çekiliyor: $(if $(SERVICES),$(SERVICES),all services)"
	@$(MAKE) --no-print-directory _run_compose MODE=deploy UP_ARGS="pull"

# --- Çekirdek ve Yardımcı Komutlar (Bunları doğrudan çağırmayın) ---

_run_compose: generate-env
	@# Bu hedef, tüm docker compose komutlarını merkezileştirir.
	@{ \
		if [ "$(MODE)" = "local" ]; then \
			COMPOSE_FILE="docker-compose.yml"; \
		else \
			COMPOSE_FILE="docker-compose.prod.yml"; \
		fi; \
		CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $$COMPOSE_FILE $(UP_ARGS) $(SERVICES); \
	}

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

.PHONY: local-up deploy down logs ps pull generate-env sync-config _run_compose