# Sentiric Orchestrator v8.0 "Symphony"
# Usage: make <command> [SERVICE=...] [PROFILE=dev|prod|core|gateway]

# --- Otomatik Konfigürasyon ---
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Kullanıcı bir profil belirtmezse, .profile.state dosyasından okur, o da yoksa 'dev' kullanır.
PROFILE ?= $(shell cat .profile.state 2>/dev/null || echo dev)

# Profile göre kullanılacak dosyaları ve env dosyasının adını belirle
ifeq ($(PROFILE),dev)
    COMPOSE_FILES := -f docker-compose.base.yml -f docker-compose.dev.yml
    ENV_CONFIG_PROFILE := dev
else ifeq ($(PROFILE),gateway)
    # Gateway, prod.yml'deki imaj tanımlarını kullanır ama sadece gateway servisini içerir.
    COMPOSE_FILES := -f docker-compose.base.yml -f docker-compose.prod.yml
    SERVICES := sip-gateway api-gateway
    ENV_CONFIG_PROFILE := gateway
else ifeq ($(PROFILE),core)
    # Core, prod.yml'deki imaj tanımlarını kullanır ama gateway servislerini hariç tutar.
    COMPOSE_FILES := -f docker-compose.base.yml -f docker-compose.prod.yml
    SERVICES := $(shell docker compose -f docker-compose.base.yml config --services | grep -v 'gateway')
    ENV_CONFIG_PROFILE := core
else # Tam üretim (prod)
    COMPOSE_FILES := -f docker-compose.base.yml -f docker-compose.prod.yml
    ENV_CONFIG_PROFILE := prod
endif
ENV_FILE := .env.$(ENV_CONFIG_PROFILE)


# --- Sezgisel Komutlar ---

start: ## ▶️ Platformu başlatır/günceller (Mevcut/Belirtilen Profil ile)
	@echo "🎻 Orkestra hazırlanıyor... Profil: $(PROFILE)"
	@echo "$(PROFILE)" > .profile.state
	@$(MAKE) _sync_config
	@$(MAKE) _generate_env
	@if [ "$(PROFILE)" = "dev" ]; then \
		echo "🚀 Kaynak koddan inşa edilerek geliştirme ortamı başlatılıyor..."; \
		CONFIG_REPO_PATH=../sentiric-config docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES) up -d --build --remove-orphans $(SERVICES); \
	else \
		echo "🚀 Hazır imajlarla '$(PROFILE)' profili dağıtılıyor..."; \
		CONFIG_REPO_PATH=../sentiric-config docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES) pull $(SERVICES); \
		CONFIG_REPO_PATH=../sentiric-config docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES) up -d --remove-orphans --no-deps $(SERVICES); \
	fi

stop: ## ⏹️ Platformu durdurur (Mevcut Profil)
	@echo "🛑 Platform durduruluyor... Profil: $(PROFILE)"
	CONFIG_REPO_PATH=../sentiric-config docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES) down

restart: ## 🔄 Platformu yeniden başlatır (Mevcut Profil)
	@$(MAKE) stop
	@$(MAKE) start

status: ## 📊 Servislerin anlık durumunu gösterir (Mevcut Profil)
	@echo "📊 Platform durumu... Profil: $(PROFILE)"
	CONFIG_REPO_PATH=../sentiric-config docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES) ps $(SERVICE)

logs: ## 📜 Servislerin loglarını canlı izler (Mevcut Profil)
	@echo "📜 Loglar izleniyor... Profil: $(PROFILE) $(if $(SERVICE),Servis: $(SERVICE),)"
	CONFIG_REPO_PATH=../sentiric-config docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES) logs -f $(SERVICE)

clean: ## 🧹 Docker ortamını TAMAMEN sıfırlar (tüm profiller, imajlar, veriler)
	@read -p "DİKKAT: TÜM Docker verileri (imajlar, volumelar dahil) silinecek. Onaylıyor musunuz? (y/N) " choice; \
	if [[ "$$choice" == "y" || "$$choice" == "Y" ]]; then \
		echo "🧹 Platform temizleniyor..."; \
		docker compose -f docker-compose.base.yml -f docker-compose.dev.yml -f docker-compose.prod.yml down -v --remove-orphans 2>/dev/null || true; \
		docker rmi -f $$(docker images -aq) 2>/dev/null || true; \
		docker builder prune -af --force 2>/dev/null || true; \
		rm -f .env.* .profile.state; \
		echo "Temizlik tamamlandı."; \
	else \
		echo "İşlem iptal edildi."; \
	fi

help: ## ℹ️ Bu yardım menüsünü gösterir
	@echo ""
	@echo "  \033[1mSentiric Orchestrator v8.0 \"Symphony\"\033[0m"
	@echo "  -------------------------------------------"
	@echo "  Kullanım: \033[36mmake <command> [PROFILE=dev|prod|core|gateway] [SERVICE=...]\033[0m"
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