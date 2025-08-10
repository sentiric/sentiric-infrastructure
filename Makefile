# Makefile - Sentiric Platform Orkestratörü v2.0 (Basitleştirilmiş)

# Varsayılan ortamı 'local' olarak ayarla
ENV ?= local
# Yapılandırma reposunun yerel yolunu belirt
CONFIG_REPO_PATH ?= ../sentiric-config
# Hedef .env dosyasının yolu
ENV_FILE := $(CONFIG_REPO_PATH)/environments/$(ENV).env

# Ana komutlar
up: sync-config
	@echo "🚀 Tüm platform '$(ENV)' ortamı için başlatılıyor..."
	# Ortama özel yapılandırma dosyasını ve CONFIG_REPO_PATH'i dışarıdan enjekte et
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml up -d --build --remove-orphans

down:
	@echo "🛑 Platform durduruluyor..."
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml down --volumes

logs:
	@echo "📜 Loglar izleniyor... (Ctrl+C ile çık)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml logs -f $(filter-out $@,$(MAKECMDGOALS))

ps:
	@echo "📊 Konteyner durumu:"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose --env-file $(ENV_FILE) -f docker-compose.yml ps

# Yapılandırma reposunu klonlar veya günceller
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