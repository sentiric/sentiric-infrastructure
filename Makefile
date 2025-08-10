# Makefile - Sentiric Platform Orkestratörü v2.2 (Ortam Standardizasyonu)

# Varsayılan ortamı 'development' olarak ayarla
ENV ?= development
# Yapılandırma reposunun yerel yolunu belirt
CONFIG_REPO_PATH ?= ../sentiric-config
# Hedef .env dosyasının yolu
ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env

# Bu, 'make logs' komutundan sonra gelen kelimeleri yakalar.
ARGS = $(filter-out $@,$(MAKECMDGOALS))

# Ana komutlar
up: sync-config
	@echo "🚀 Tüm platform '$(ENV)' ortamı için başlatılıyor..."
	# ENV değişkenini Makefile'dan Docker Compose'a aktarıyoruz
	ENV=$(ENV) CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans

down:
	@echo "🛑 Platform durduruluyor..."
	ENV=$(ENV) CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml down --volumes

# ... (logs ve ps hedefleri aynı kalabilir) ...
logs:
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	ENV=$(ENV) CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml logs -f $(ARGS)

ps:
	@echo "📊 Konteyner durumu:"
	ENV=$(ENV) CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml ps

# ... (sync-config hedefi aynı kalacak) ...
sync-config:
	@if [ ! -d "$(CONFIG_REPO_PATH)" ]; then \
		echo "🛠️ Güvenli yapılandırma reposu klonlanıyor..."; \
		git clone git@github.com:sentiric/sentiric-config.git $(CONFIG_REPO_PATH); \
	else \
		echo "🔄 Güvenli yapılandırma reposu güncelleniyor..."; \
		(cd $(CONFIG_REPO_PATH) && git pull); \
	fi
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "❌ HATA: '$(ENV)' ortamı için yapılandırma dosyası bulunamadı: $(ENV_FILE)"; \
		exit 1; \
	fi

.PHONY: up down logs ps sync-config

%:
	@: