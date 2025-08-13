# Sentiric Orchestrator v10.3 "Final Stand"
SHELL := /bin/bash
.DEFAULT_GOAL := help

# --- Otomatik Konfigürasyon ---
PROFILE ?= $(shell cat .profile.state 2>/dev/null || echo dev)
CONFIG_REPO_PATH := ../sentiric-config
SOURCE_ENV_FILE := $(CONFIG_REPO_PATH)/environments/profiles/$(PROFILE).env
TARGET_ENV_FILE := .env.generated

# Profile göre kullanılacak dosyayı belirle
ifeq ($(PROFILE),core)
    COMPOSE_FILES := -f docker-compose.core.yml
else ifeq ($(PROFILE),gateway)
    COMPOSE_FILES := -f docker-compose.gateway.yml
else # Varsayılan dev
    COMPOSE_FILES := -f docker-compose.dev.yml
endif

# --- Sezgisel Komutlar ---

start: ## ▶️ Platformu başlatır/günceller (Mevcut/Belirtilen Profil ile)
	@echo "🎻 Orkestra hazırlanıyor... Profil: $(PROFILE)"
	@echo "$(PROFILE)" > .profile.state
	@$(MAKE) _sync_config
	@$(MAKE) _generate_env
	@if [ "$(PROFILE)" = "dev" ]; then \
		echo "🚀 Kaynak koddan inşa edilerek geliştirme ortamı başlatılıyor..."; \
		docker compose -p sentiric-$(PROFILE) --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) up -d --build --remove-orphans $(SERVICE); \
	else \
		echo "🚀 Hazır imajlarla '$(PROFILE)' profili dağıtılıyor..."; \
		docker compose -p sentiric-$(PROFILE) --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) pull $(SERVICE); \
		docker compose -p sentiric-$(PROFILE) --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) up -d --remove-orphans --no-deps $(SERVICE); \
	fi

# ... (stop, restart, status, logs, clean, help hedefleri önceki gibi kalabilir, onlarda bir sorun yoktu) ...
stop: ## ⏹️ Platformu durdurur (Mevcut Profil)
	@echo "🛑 Platform durduruluyor... Profil: $(PROFILE)"
	@if [ -f "$(firstword $(subst -f ,,$(COMPOSE_FILES)))" ]; then \
		docker compose -p sentiric-$(PROFILE) --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) down -v; \
	fi

restart: ## 🔄 Platformu yeniden başlatır (Mevcut Profil)
	@$(MAKE) stop; $(MAKE) start

status: ## 📊 Servislerin anlık durumunu gösterir (Mevcut Profil)
	@echo "📊 Platform durumu... Profil: $(PROFILE)"
	@if [ -f "$(firstword $(subst -f ,,$(COMPOSE_FILES)))" ]; then \
		docker compose -p sentiric-$(PROFILE) --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) ps $(SERVICE); \
	fi

logs: ## 📜 Servislerin loglarını canlı izler (Mevcut Profil)
	@echo "📜 Loglar izleniyor... Profil: $(PROFILE) $(if $(SERVICE),Servis: $(SERVICE),)"
	@if [ -f "$(firstword $(subst -f ,,$(COMPOSE_FILES)))" ]; then \
		docker compose -p sentiric-$(PROFILE) --env-file $(TARGET_ENV_FILE) $(COMPOSE_FILES) logs -f $(SERVICE); \
	fi

clean: ## 🧹 Docker ortamını TAMAMEN sıfırlar
	@read -p "DİKKAT: TÜM Docker verileri silinecek. Onaylıyor musunuz? (y/N) " choice; \
	if [[ "$$choice" == "y" || "$$choice" == "Y" ]]; then \
		echo "🧹 Platform temizleniyor..."; \
		docker compose -p sentiric-dev -f docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || true; \
		docker compose -p sentiric-core -f docker-compose.core.yml down -v --remove-orphans 2>/dev/null || true; \
		docker compose -p sentiric-gateway -f docker-compose.gateway.yml down -v --remove-orphans 2>/dev/null || true; \
		rm -f .env.* .profile.state; \
		echo "Temizlik tamamlandı."; \
	else \
		echo "İşlem iptal edildi."; \
	fi

help: ## ℹ️ Bu yardım menüsünü gösterir
	@echo "Sentiric Orchestrator v10.3"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

# --- Dahili Yardımcı Komutlar ---
_generate_env:
	@echo "🔧 Yapılandırma dosyası '$(TARGET_ENV_FILE)' oluşturuluyor (Profil: $(PROFILE))..."
	@cp "$(SOURCE_ENV_FILE)" "$(TARGET_ENV_FILE)"
	@echo "\n# Dynamically added by Orchestrator" >> "$(TARGET_ENV_FILE)"
	@DETECTED_IP=$$(ip route get 1.1.1.1 2>/dev/null | awk '{print $$7}' || hostname -I | awk '{print $$1}'); \
	echo "PUBLIC_IP=$${DETECTED_IP}" >> "$(TARGET_ENV_FILE)"
	@echo "TAG=${TAG:-latest}" >> "$(TARGET_ENV_FILE)"

_sync_config:
	@if [ ! -d "$(CONFIG_REPO_PATH)" ]; then \
		echo "🛠️ Güvenli yapılandırma reposu klonlanıyor..."; \
		git clone git@github.com:sentiric/sentiric-config.git $(CONFIG_REPO_PATH); \
	else \
		echo "🔄 Güvenli yapılandırma reposu güncelleniyor..."; \
		(cd $(CONFIG_REPO_PATH) && git pull); \
	fi

.PHONY: start stop restart status logs clean help _generate_env _sync_config