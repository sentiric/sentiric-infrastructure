# Sentiric Orchestrator v10.0 "Rock Solid"
# Usage: make <command> [PROFILE=dev|core|gateway] [SERVICE=...]

SHELL := /bin/bash
.DEFAULT_GOAL := help

# --- Otomatik Konfigürasyon ---
PROFILE ?= $(shell cat .profile.state 2>/dev/null || echo dev)
ENV_FILE := .env.$(PROFILE)
CONFIG_REPO_PATH := ../sentiric-config
ENV_CONFIG_PROFILE := $(PROFILE)

# Profile göre kullanılacak dosyayı belirle
ifeq ($(PROFILE),core)
    COMPOSE_FILE := -f docker-compose.core.yml
else ifeq ($(PROFILE),gateway)
    COMPOSE_FILES := -f docker-compose.gateway.yml
else # Varsayılan dev
    COMPOSE_FILES := -f docker-compose.dev.yml
endif

# --- Sezgisel Komutlar ---
# NOT: Artık tüm komutlar CONFIG_REPO_PATH değişkenini doğrudan Docker Compose'a iletiyor.
# Bu, WSL'deki uyarıları ortadan kaldıracak.

start: ## ▶️ Platformu başlatır/günceller (Mevcut/Belirtilen Profil ile)
	@echo "🎻 Orkestra hazırlanıyor... Profil: $(PROFILE)"
	@echo "$(PROFILE)" > .profile.state
	@$(MAKE) _sync_config
	@$(MAKE) _generate_env
	@if [ "$(PROFILE)" = "dev" ]; then \
		echo "🚀 Kaynak koddan inşa edilerek geliştirme ortamı başlatılıyor..."; \
		CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) up -d --build --remove-orphans $(SERVICE); \
	else \
		echo "🚀 Hazır imajlarla '$(PROFILE)' profili dağıtılıyor..."; \
		CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) pull $(SERVICE); \
		CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) up -d --remove-orphans --no-deps $(SERVICE); \
	fi

stop: ## ⏹️ Platformu durdurur (Mevcut Profil)
	@echo "🛑 Platform durduruluyor... Profil: $(PROFILE)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) down -v

restart: ## 🔄 Platformu yeniden başlatır (Mevcut Profil)
	@$(MAKE) stop
	@$(MAKE) start

status: ## 📊 Servislerin anlık durumunu gösterir (Mevcut Profil)
	@echo "📊 Platform durumu... Profil: $(PROFILE)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) ps $(SERVICE)

logs: ## 📜 Servislerin loglarını canlı izler (Mevcut Profil)
	@echo "📜 Loglar izleniyor... Profil: $(PROFILE) $(if $(SERVICE),Servis: $(SERVICE),)"
	CONFIG_REPO_PATH=$(CONFIG_REPO_PATH) docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) logs -f $(SERVICE)

# ... (clean ve help komutları aynı kalabilir) ...
clean: ## 🧹 Docker ortamını TAMAMEN sıfırlar (tüm profiller, imajlar, veriler)
	@read -p "DİKKAT: TÜM Docker verileri silinecek. Onaylıyor musunuz? (y/N) " choice; \
	if [[ "$$choice" == "y" || "$$choice" == "Y" ]]; then \
		echo "🧹 Platform temizleniyor..."; \
		docker compose -p sentiric-dev down -v --remove-orphans 2>/dev/null || true; \
		docker compose -p sentiric-core down -v --remove-orphans 2>/dev/null || true; \
		docker compose -p sentiric-gateway down -v --remove-orphans 2>/dev/null || true; \
		docker rm -f $$(docker ps -aq) 2>/dev/null || true; \
		docker rmi -f $$(docker images -q) 2>/dev/null || true; \
		docker volume prune -f 2>/dev/null || true; \
		docker network prune -f 2>/dev/null || true; \
		docker builder prune -af --force 2>/dev/null || true; \
		rm -f .env.* .profile.state; \
		echo "Temizlik tamamlandı."; \
	else \
		echo "İşlem iptal edildi."; \
	fi

help: ## ℹ️ Bu yardım menüsünü gösterir
	@echo ""
	@echo "  \033[1mSentiric Orchestrator v10.0 \"Rock Solid\"\033[0m"
	@echo "  -------------------------------------------"
	@echo "  Kullanım: \033[36mmake <command> [PROFILE=dev|core|gateway] [SERVICE=...]\033[0m"
	@echo ""
	@echo "  \033[1mKomutlar:\033[0m"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Örnekler:"
	@echo "    \033[32mmake start PROFILE=core\033[0m      # Çekirdek servisleri imajdan başlatır ve profili kaydeder."
	@echo "    \033[32mmake start\033[0m                   # Kayıtlı profili (veya dev) kullanarak başlatır."
	@echo "    \033[32mmake logs SERVICE=agent-service\033[0m # Mevcut profildeki agent loglarını izler."
	@echo ""


# --- Dahili Yardımcı Komutlar ---
_generate_env:
	@bash scripts/generate-env.sh $(ENV_CONFIG_PROFILE)

_sync_config:
	@if [ ! -d "../sentiric-config" ]; then \
		echo "🛠️ Güvenli yapılandırma reposu klonlanıyor..."; \
		git clone git@github.com:sentiric/sentiric-config.git ../sentiric-config; \
	else \
		echo "🔄 Güvenli yapılandırma reposu güncelleniyor..."; \
		(cd ../sentiric-config && git pull); \
	fi

.PHONY: start stop restart status logs clean help _generate_env _sync_config