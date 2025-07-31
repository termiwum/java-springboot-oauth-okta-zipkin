# Makefile para Ecosistema de Microservicios
# Facilita la gestión del entorno Docker Compose

.PHONY: help build up down logs clean restart status health

# Variables
COMPOSE_FILE = docker-compose.yml
ENV_FILE = .env

# Colores para output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## 📋 Mostrar ayuda
	@echo "$(GREEN)🚀 Comandos disponibles para el Ecosistema de Microservicios:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)📖 Ejemplos de uso:$(NC)"
	@echo "  make build     # Construir todas las imágenes"
	@echo "  make up        # Levantar todo el ecosistema"
	@echo "  make logs      # Ver logs en tiempo real"
	@echo "  make down      # Detener todo"
	@echo ""

build: ## 🏗️  Construir todas las imágenes Docker
	@echo "$(GREEN)🏗️  Construyendo imágenes Docker...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build --no-cache
	@echo "$(GREEN)✅ Imágenes construidas exitosamente$(NC)"

build-quick: ## ⚡ Construir imágenes Docker (con cache)
	@echo "$(GREEN)⚡ Construyendo imágenes Docker (rápido)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build
	@echo "$(GREEN)✅ Imágenes construidas exitosamente$(NC)"

up: ## 🚀 Levantar todo el ecosistema
	@echo "$(GREEN)🚀 Levantando ecosistema de microservicios...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)✅ Ecosistema iniciado$(NC)"
	@echo ""
	@echo "$(YELLOW)🌐 URLs de acceso:$(NC)"
	@echo "  • API Gateway:     http://localhost:9090"
	@echo "  • Eureka Dashboard: http://localhost:8761"
	@echo "  • Config Server:   http://localhost:9296"
	@echo "  • Zipkin UI:       http://localhost:9411"
	@echo ""

up-build: ## 🚀 Construir y levantar todo el ecosistema
	@echo "$(GREEN)🚀 Construyendo y levantando ecosistema...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build
	@echo "$(GREEN)✅ Ecosistema iniciado$(NC)"

down: ## 🛑 Detener todo el ecosistema
	@echo "$(YELLOW)🛑 Deteniendo ecosistema...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down
	@echo "$(GREEN)✅ Ecosistema detenido$(NC)"

down-volumes: ## 🧹 Detener y eliminar volúmenes (CUIDADO: Borra datos de BD)
	@echo "$(RED)🧹 Deteniendo ecosistema y eliminando volúmenes...$(NC)"
	@echo "$(RED)⚠️  ADVERTENCIA: Esto eliminará todos los datos de las bases de datos$(NC)"
	@read -p "¿Estás seguro? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down -v; \
		echo "$(GREEN)✅ Ecosistema y volúmenes eliminados$(NC)"; \
	else \
		echo "$(YELLOW)❌ Operación cancelada$(NC)"; \
	fi

restart: ## 🔄 Reiniciar todo el ecosistema
	@echo "$(YELLOW)🔄 Reiniciando ecosistema...$(NC)"
	make down
	make up
	@echo "$(GREEN)✅ Ecosistema reiniciado$(NC)"

restart-service: ## 🔄 Reiniciar un servicio específico (uso: make restart-service SERVICE=nombre)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)❌ Especifica el servicio: make restart-service SERVICE=nombre$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔄 Reiniciando servicio $(SERVICE)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) restart $(SERVICE)
	@echo "$(GREEN)✅ Servicio $(SERVICE) reiniciado$(NC)"

logs: ## 📋 Ver logs de todos los servicios en tiempo real
	@echo "$(GREEN)📋 Mostrando logs en tiempo real (Ctrl+C para salir)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

logs-service: ## 📋 Ver logs de un servicio específico (uso: make logs-service SERVICE=nombre)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)❌ Especifica el servicio: make logs-service SERVICE=nombre$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)📋 Mostrando logs de $(SERVICE)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f $(SERVICE)

status: ## 📊 Ver estado de todos los servicios
	@echo "$(GREEN)📊 Estado de los servicios:$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) ps

health: ## 🏥 Verificar salud de todos los servicios
	@echo "$(GREEN)🏥 Verificando salud de servicios...$(NC)"
	@echo ""
	@echo "$(YELLOW)Service Registry (Eureka):$(NC)"
	@curl -s http://localhost:8761/actuator/health | jq . 2>/dev/null || echo "❌ No disponible"
	@echo ""
	@echo "$(YELLOW)Config Server:$(NC)"
	@curl -s http://localhost:9296/actuator/health | jq . 2>/dev/null || echo "❌ No disponible"
	@echo ""
	@echo "$(YELLOW)API Gateway:$(NC)"
	@curl -s http://localhost:9090/actuator/health | jq . 2>/dev/null || echo "❌ No disponible"
	@echo ""
	@echo "$(YELLOW)Zipkin:$(NC)"
	@curl -s http://localhost:9411/health | jq . 2>/dev/null || echo "❌ No disponible"

clean: ## 🧹 Limpieza completa del entorno Docker
	@echo "$(RED)🧹 Realizando limpieza completa...$(NC)"
	@echo "$(RED)⚠️  ADVERTENCIA: Esto eliminará imágenes, contenedores y volúmenes$(NC)"
	@read -p "¿Estás seguro? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down -v --rmi all --remove-orphans; \
		docker system prune -f; \
		echo "$(GREEN)✅ Limpieza completa realizada$(NC)"; \
	else \
		echo "$(YELLOW)❌ Operación cancelada$(NC)"; \
	fi

rebuild: ## 🔨 Reconstruir un servicio específico (uso: make rebuild SERVICE=nombre)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)❌ Especifica el servicio: make rebuild SERVICE=nombre$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔨 Reconstruyendo servicio $(SERVICE)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build --no-cache $(SERVICE)
	docker-compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d $(SERVICE)
	@echo "$(GREEN)✅ Servicio $(SERVICE) reconstruido e iniciado$(NC)"

open-urls: ## 🌐 Abrir todas las URLs principales en el navegador
	@echo "$(GREEN)🌐 Abriendo URLs en el navegador...$(NC)"
	@if command -v xdg-open > /dev/null; then \
		xdg-open http://localhost:8761 & \
		xdg-open http://localhost:9090 & \
		xdg-open http://localhost:9411 & \
	elif command -v open > /dev/null; then \
		open http://localhost:8761 & \
		open http://localhost:9090 & \
		open http://localhost:9411 & \
	elif command -v start > /dev/null; then \
		start http://localhost:8761 & \
		start http://localhost:9090 & \
		start http://localhost:9411 & \
	else \
		echo "$(YELLOW)⚠️  No se pudo abrir automáticamente. URLs disponibles:$(NC)"; \
		echo "  • Eureka: http://localhost:8761"; \
		echo "  • Gateway: http://localhost:9090"; \
		echo "  • Zipkin: http://localhost:9411"; \
	fi

# Aliases para facilidad de uso
start: up ## 🚀 Alias para 'up'
stop: down ## 🛑 Alias para 'down'
ps: status ## 📊 Alias para 'status'

# Default target
.DEFAULT_GOAL := help
