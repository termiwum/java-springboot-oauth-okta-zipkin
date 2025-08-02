#!/bin/bash

# Script de Test Automatizado del Ecosistema de Microservicios
# Ejecuta todos los tests de manera secuencial o paralela

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Parámetros por defecto
MODE="sequential"
DURATION=5
SKIP_SETUP=false

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}🚀 Script de Test Automatizado del Ecosistema de Microservicios${NC}"
    echo ""
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  -m, --mode MODE        Modo de ejecución: sequential, parallel, global, individual (default: sequential)"
    echo "  -d, --duration MINS    Duración en minutos por test (default: 5)"
    echo "  -s, --skip-setup       Omitir verificación de prerrequisitos"
    echo "  -h, --help             Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0                                    # Ejecutar todos los tests secuencialmente"
    echo "  $0 -m parallel -d 3                  # Ejecutar en paralelo por 3 minutos cada uno"
    echo "  $0 -m global -d 10                   # Solo test global por 10 minutos"
    echo "  $0 -m individual                     # Seleccionar test específico"
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -s|--skip-setup)
            SKIP_SETUP=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opción desconocida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Validar modo
if [[ ! "$MODE" =~ ^(sequential|parallel|global|individual)$ ]]; then
    echo -e "${RED}❌ Modo inválido: $MODE${NC}"
    echo -e "${YELLOW}Modos válidos: sequential, parallel, global, individual${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Iniciando Test Automatizado del Ecosistema de Microservicios${NC}"
echo -e "${CYAN}📊 Modo: $MODE | Duración: $DURATION minutos por test${NC}"

# Verificar prerrequisitos
if [[ "$SKIP_SETUP" == false ]]; then
    echo -e "\n${YELLOW}🔍 Verificando prerrequisitos...${NC}"
    
    # Verificar que Docker esté corriendo
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker está funcionando${NC}"
    else
        echo -e "${RED}❌ Docker no está disponible. Inicia Docker.${NC}"
        exit 1
    fi
    
    # Verificar que K6 esté instalado
    if command -v k6 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ K6 está instalado${NC}"
    else
        echo -e "${RED}❌ K6 no está instalado. Instala K6 primero.${NC}"
        exit 1
    fi
    
    # Verificar que el stack de monitoreo esté corriendo
    services=("influxdb" "grafana")
    for service in "${services[@]}"; do
        if docker ps --filter "name=$service" --format "table {{.Names}}" | grep -q "$service"; then
            echo -e "${GREEN}✅ $service está corriendo${NC}"
        else
            echo -e "${YELLOW}⚠️  $service no está corriendo. Iniciando stack de monitoreo...${NC}"
            docker-compose -f stress-testing/docker-compose-monitoring.yml up -d
            sleep 10
            break
        fi
    done
    
    # Verificar que los servicios principales estén corriendo
    main_services=(
        "cloud-gateway:9090"
        "service-registry:8761"
        "config-server:8888"
    )
    
    for service_port in "${main_services[@]}"; do
        IFS=':' read -r service port <<< "$service_port"
        if curl -s "http://localhost:$port/actuator/health" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $service está disponible en puerto $port${NC}"
        else
            echo -e "${RED}❌ $service no está disponible en puerto $port${NC}"
            echo -e "${YELLOW}   Asegúrate de que el stack principal esté corriendo${NC}"
        fi
    done
fi

# Configurar variables de entorno para K6
export K6_OUT="influxdb=http://localhost:8086/stress-testing-token"
export K6_INFLUXDB_ORGANIZATION="stress-testing"
export K6_INFLUXDB_BUCKET="k6-metrics"

# Definir tests disponibles
declare -a tests=(
    "Order Place Test:order-place-test.js:Test de creación de pedidos con comunicación Order->Product->Payment"
    "Order Details Test:order-details-test.js:Test de consulta de detalles con comunicación Order->Product+Payment"
    "Payment Service Test:payment-service-test.js:Test completo del servicio de pagos"
    "Product Service Test:product-service-test.js:Test completo del servicio de productos"
    "Ecosystem Global Test:ecosystem-global-test.js:Test global del ecosistema completo"
)

# Función para ejecutar un test K6
run_k6_test() {
    local test_file="$1"
    local test_name="$2"
    local description="$3"
    local duration_minutes="$4"
    
    echo -e "\n${MAGENTA}🔥 Ejecutando: $test_name${NC}"
    echo -e "${GRAY}📝 $description${NC}"
    
    local test_path="stress-testing/k6-scripts/$test_file"
    
    if [[ ! -f "$test_path" ]]; then
        echo -e "${RED}❌ Archivo de test no encontrado: $test_path${NC}"
        return 1
    fi
    
    local start_time=$(date +%s)
    
    if k6 run --duration="${duration_minutes}m" --vus=20 "$test_path"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        
        echo -e "${GREEN}✅ $test_name completado en ${minutes}m ${seconds}s${NC}"
        return 0
    else
        echo -e "${RED}❌ Error ejecutando $test_name${NC}"
        return 1
    fi
}

# Función para ejecutar tests en paralelo
run_parallel_tests() {
    echo -e "\n${CYAN}🚀 Ejecutando tests en paralelo...${NC}"
    
    local pids=()
    local test_names=()
    
    # Ejecutar tests individuales en paralelo (excepto el global)
    for test in "${tests[@]}"; do
        IFS=':' read -r name file description <<< "$test"
        
        if [[ "$file" != "ecosystem-global-test.js" ]]; then
            echo -e "${YELLOW}🔄 Iniciando: $name${NC}"
            
            (
                export K6_OUT="influxdb=http://localhost:8086/stress-testing-token"
                export K6_INFLUXDB_ORGANIZATION="stress-testing"
                export K6_INFLUXDB_BUCKET="k6-metrics"
                
                k6 run --duration="${DURATION}m" --vus=15 "stress-testing/k6-scripts/$file"
            ) &
            
            pids+=($!)
            test_names+=("$name")
        fi
    done
    
    # Esperar a que todos los procesos terminen
    echo -e "\n${YELLOW}⏳ Esperando a que terminen todos los tests paralelos...${NC}"
    
    for i in "${!pids[@]}"; do
        wait "${pids[i]}"
        echo -e "${GREEN}✅ ${test_names[i]} terminado${NC}"
    done
    
    echo -e "\n${GREEN}🎉 Todos los tests paralelos completados${NC}"
}

# Función para seleccionar test individual
select_individual_test() {
    echo -e "\n${CYAN}🎯 Selecciona el test a ejecutar:${NC}"
    
    for i in "${!tests[@]}"; do
        IFS=':' read -r name file description <<< "${tests[i]}"
        echo -e "   $((i + 1)). ${YELLOW}$name${NC}"
        echo -e "      ${GRAY}$description${NC}"
    done
    
    while true; do
        echo ""
        read -p "Ingresa el número del test (1-${#tests[@]}): " selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le "${#tests[@]}" ]]; then
            break
        else
            echo -e "${RED}❌ Selección inválida. Ingresa un número entre 1 y ${#tests[@]}.${NC}"
        fi
    done
    
    local selected_index=$((selection - 1))
    IFS=':' read -r name file description <<< "${tests[selected_index]}"
    
    run_k6_test "$file" "$name" "$description" "$DURATION"
}

# Ejecutar según el modo seleccionado
case "$MODE" in
    "sequential")
        echo -e "\n${CYAN}📋 Ejecutando tests secuencialmente...${NC}"
        
        declare -a results=()
        
        for test in "${tests[@]}"; do
            IFS=':' read -r name file description <<< "$test"
            
            if run_k6_test "$file" "$name" "$description" "$DURATION"; then
                results+=("$name:SUCCESS")
            else
                results+=("$name:ERROR")
            fi
            
            echo -e "${YELLOW}⏳ Pausa de 30 segundos antes del siguiente test...${NC}"
            sleep 30
        done
        
        # Mostrar resumen
        echo -e "\n${CYAN}📊 RESUMEN DE RESULTADOS:${NC}"
        for result in "${results[@]}"; do
            IFS=':' read -r test_name status <<< "$result"
            if [[ "$status" == "SUCCESS" ]]; then
                echo -e "   ${GREEN}✅ $test_name: ÉXITO${NC}"
            else
                echo -e "   ${RED}❌ $test_name: ERROR${NC}"
            fi
        done
        ;;
        
    "parallel")
        run_parallel_tests
        ;;
        
    "global")
        echo -e "\n${CYAN}🌐 Ejecutando solo test global del ecosistema...${NC}"
        for test in "${tests[@]}"; do
            IFS=':' read -r name file description <<< "$test"
            if [[ "$file" == "ecosystem-global-test.js" ]]; then
                run_k6_test "$file" "$name" "$description" "$((DURATION * 2))"
                break
            fi
        done
        ;;
        
    "individual")
        select_individual_test
        ;;
esac

echo -e "\n${GREEN}🎯 TESTS COMPLETADOS${NC}"
echo -e "${CYAN}📊 Accede a Grafana para ver los resultados: http://localhost:3000${NC}"
echo -e "${CYAN}🔍 Revisa las trazas en Zipkin: http://localhost:9411${NC}"
echo -e "${CYAN}💾 Los datos están almacenados en InfluxDB: http://localhost:8086${NC}"
