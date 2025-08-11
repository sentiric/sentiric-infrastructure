# Makefile - Sentiric Platform Orkestratörü v4.4 (Güvenilir Servis Seçimi)

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
# Bu blok, tüm docker compose komutlarını tek bir yerden yönetir.
COMPOSE_CMD = CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) TAG=$(TAG) docker compose --env-file $(TARGET_ENV_FILE) -f $(COMPOSE_FILE)

# --- Kullanıcı Dostu Komutlar ---
# Bu özel hedef, make'e verilen diğer tüm argümanları yakalar.
# Örn: `make local-up agent-service` -> `ARGS` = `agent-service`
%:
	@:

# Yerel geliştirme için
local-up: generate-env
	@$(COMPOSE_CMD) up -d --build --remove-orphans $(filter-out $@,$(MAKECMDGOALS))

# Dağıtım için (önce pull eder, sonra up yapar)
deploy: generate-env
	@echo "🚀 Platform '$(ENV)' ortamı için [ghcr.io] imajları (TAG: $(TAG)) ile başlatılıyor..."
	@echo "--- Adım 1/2: İmajlar güncelleniyor: $(if $(filter-out $@,$(MAKECMDGOALS)),$(filter-out $@,$(MAKECMDGOALS)),all services)"
	@$(COMPOSE_CMD) pull $(filter-out $@,$(MAKECMDGOALS))
	@echo "--- Adım 2/2: Konteynerler başlatılıyor..."
	@$(COMPOSE_CMD) up -d --remove-orphans $(filter-out $@,$(MAKECMDGOALS))

# Sadece imajları çekmek için
pull: generate-env
	@echo "🔄 İmajlar çekiliyor: $(if $(filter-out $@,$(MAKECMDGOALS)),$(filter-out $@,$(MAKECMDGOALS)),all services)"
	@$(COMPOSE_CMD) pull $(filter-out $@,$(MAKECMDGOALS))

# Sistemi durdurmak için
down: generate-env
	@echo "🛑 Platform durduruluyor..."
	@$(COMPOSE_CMD) down --volumes
	@echo "🧹 Geçici yapılandırma dosyası ($(TARGET_ENV_FILE)) temizleniyor..."
	@rm -f $(TARGET_ENV_FILE)

# Logları izlemek için
logs: generate-env
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	@$(COMPOSE_CMD) logs -f $(filter-out $@,$(MAKECMDGOALS))

# Konteyner durumunu görmek için
ps: generate-env
	@echo "📊 Konteyner durumu:"
	@$(COMPOSE_CMD) ps $(filter-out $@,$(MAKECMDGOALS))

# --- Yardımcı Komutlar ---
generate-env: sync-config
	@# ... (bu bölüm bir önceki versiyonla aynı, değiştirmiyoruz) ...
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
	@# ... (bu bölüm de aynı kalabilir) ...
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

.PHONY: local-up deploy up down pull logs ps generate-env sync-config