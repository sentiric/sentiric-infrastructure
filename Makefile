# Makefile - Sentiric Platform Orkestratörü v5.3 (Hibrit Destekli ve Temiz)

# --- Değişkenler ---
# Kullanım: make [hedef] ENV=[ortam] SERVICES="servis1 servis2..." TAG=[etiket]
ENV ?= development
TAG ?= latest
SERVICES ?=

# --- Dosya Yolları ---
CONFIG_REPO_PATH := ../sentiric-config
COMMON_ENV_FILE := $(CONFIG_REPO_PATH)/environments/common.env
SPECIFIC_ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env
TARGET_ENV_FILE := .env.generated
DETECTED_IP := $(shell ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}')
# vpc in ip adresi bunu tanımlamaz isek call end olayı çalışmıyor / ancak çağrı geliyor
DETECTED_IP := 34.122.40.122
# --- Ana Komutlar ---

# Yerel geliştirme için (kaynak koddan inşa eder)
up: generate-env
	@echo "▶️  Yerel geliştirme ortamı ($(ENV)) başlatılıyor: $(if $(SERVICES),$(SERVICES),tüm servisler)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans $(SERVICES)

# Dağıtım için (hazır imajları çeker)
deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile dağıtılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICES)
	@echo "--- Adım 2/2: Konteynerler başlatılıyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml up -d --remove-orphans --no-deps $(SERVICES)

# Sistemi durdurmak ve TÜM verileri temizlemek için
down:
	@echo "🛑 Platform durduruluyor ve tüm veriler (volume'ler) siliniyor..."
	# generate-env'i burada çağırmamıza gerek yok, sadece dosyaların varlığı yeterli.
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

# --- Yönetim Komutları ---
logs:
	@echo "📜 Loglar izleniyor: $(if $(SERVICES),$(SERVICES),tüm servisler)... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml logs -f $(SERVICES)

ps:
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.yml -f docker-compose.prod.yml ps $(SERVICES)

pull: generate-env
	@echo "🔄 İmajlar çekiliyor: $(if $(SERVICES),$(SERVICES),tüm servisler)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f docker-compose.prod.yml pull $(SERVICES)
	
prune:
	@echo "🧹 Docker build cache'i ve kullanılmayan imajlar temizleniyor..."
	@docker builder prune -f
	@docker image prune -f

# --- Hibrit Dağıtım Kısayolları ---
deploy-gateway:
	@$(MAKE) deploy ENV=gcp_gateway_only SERVICES="sip-gateway"

deploy-core:
	@$(MAKE) deploy ENV=wsl_core_services SERVICES="postgres rabbitmq redis qdrant user-service dialplan-service media-service sip-signaling agent-service llm-service stt-service connectors-service task-service task-service-worker flower knowledge-service messaging-gateway api-gateway dashboard-ui web-agent-ui"


# --- Yardımcı Komutlar ---
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

.PHONY: up deploy down logs ps pull prune deploy-gateway deploy-core generate-env sync-config