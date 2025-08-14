# Sentiric Orchestrator v12.0 "Final Conductor"
# Usage: make <command> [PROFILE=dev|core|gateway] [SERVICE=...]

SHELL := /bin/bash
.DEFAULT_GOAL := help

# --- Otomatik Konfigürasyon ---
PROFILE ?= $(shell cat .profile.state 2>/dev/null || echo dev)
ENV_FILE := .env.generated

ifeq ($(PROFILE),core)
    COMPOSE_FILES := -f docker-compose.core.yml
    ENV_CONFIG_PROFILE := core
else ifeq ($(PROFILE),gateway)
    COMPOSE_FILES := -f docker-compose.gateway.yml
    ENV_CONFIG_PROFILE := gateway
else # Varsayılan dev
    COMPOSE_FILES := -f docker-compose.dev.yml
    ENV_CONFIG_PROFILE := dev
endif

# --- Sezgisel Komutlar ---

start: _sync_config _generate_env ## ▶️ Platformu başlatır/günceller
	@echo "🎻 Orkestra hazırlanıyor... Profil: $(PROFILE)"
	@echo "$(PROFILE)" > .profile.state
	@if [ "$(PROFILE)" = "dev" ]; then \
		echo "🚀 Kaynak koddan inşa edilerek geliştirme ortamı başlatılıyor..."; \
		docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) up -d --build --remove-orphans $(SERVICE); \
	else \
		echo "🚀 Hazır imajlarla '$(PROFILE)' profili dağıtılıyor..."; \
		docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) pull $(SERVICE); \
		docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) up -d --remove-orphans --no-deps $(SERVICE); \
	fi

stop: _generate_env ## ⏹️ Platformu durdurur
	@echo "🛑 Platform durduruluyor... Profil: $(PROFILE)"
	@if [ -f "$(firstword $(subst -f ,,$(COMPOSE_FILES)))" ]; then \
		docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) down -v; \
	fi

restart: ## 🔄 Platformu yeniden başlatır
	@$(MAKE) stop; $(MAKE) start

status: ## 📊 Servislerin durumunu gösterir
	@echo "📊 Platform durumu... Profil: $(PROFILE)"
	@if [ -f "$(firstword $(subst -f ,,$(COMPOSE_FILES)))" ]; then \
		docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) ps $(SERVICE); \
	fi

logs: ## 📜 Servislerin loglarını canlı izler
	@echo "📜 Loglar izleniyor... Profil: $(PROFILE) $(if $(SERVICE),Servis: $(SERVICE),)"
	@if [ -f "$(firstword $(subst -f ,,$(COMPOSE_FILES)))" ]; then \
		docker compose -p sentiric-$(PROFILE) --env-file $(ENV_FILE) $(COMPOSE_FILES) logs -f $(SERVICE); \
	fi

clean: ## 🧹 Docker ortamını TAMAMEN sıfırlar
	@read -p "DİKKAT: TÜM Docker verileri silinecek. Onaylıyor musunuz? (y/N) " choice; \
	if [[ "$$choice" == "y" || "$$choice" == "Y" ]]; then \
		echo "🧹 Platform temizleniyor..."; \
		docker compose -p sentiric-dev -f docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || true; \
		docker compose -p sentiric-core -f docker-compose.core.yml down -v --remove-orphans 2>/dev/null || true; \
		docker compose -p sentiric-gateway -f docker-compose.gateway.yml down -v --remove-orphans 2>/dev/null || true; \
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
	@echo "  \033[1mSentiric Orchestrator v12.0 \"Final Conductor\"\033[0m"
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