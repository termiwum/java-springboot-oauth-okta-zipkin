# 🔥 Stress Testing & Monitoring Stack

## 📋 Descripción

Este módulo proporciona una solución completa de **stress testing** y **monitoreo** para el ecosistema de microservices Spring Boot. Combina **K6** para pruebas de carga con un stack híbrido de monitoreo usando **Prometheus**, **InfluxDB** y **Grafana**.

## 🔒 IMPORTANTE: Configuración de Credenciales

### ⚡ Setup Rápido de Auth0

```bash
# 1. Copiar archivo de ejemplo
cp .env.example .env

# 2. Editar .env con credenciales reales (NO subir a Git)
AUTH0_DOMAIN=tu-dominio.auth0.com
AUTH0_CLIENT_ID=tu_client_id
AUTH0_CLIENT_SECRET=tu_client_secret
AUTH0_AUDIENCE=https://tu-dominio.auth0.com/api/v2/
```

### 🚫 Seguridad
- ✅ `.env` está en `.gitignore` (no se sube a Git)
- ✅ Usar `.env.example` como template
- ⚠️ **NUNCA** subas credenciales reales al repositorio

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   K6 Testing    │───▶│    InfluxDB     │───▶│     Grafana     │
└─────────────────┘    └─────────────────┘    │   (Dashboards)  │
                                              │                 │
┌─────────────────┐    ┌─────────────────┐    │                 │
│ Spring Boot Apps│───▶│   Prometheus    │───▶│                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🎯 Stack Híbrido de Monitoreo

- **InfluxDB**: Almacena métricas de tiempo real de K6 (load testing)
- **Prometheus**: Recolecta métricas de aplicaciones Spring Boot (actuator)
- **Grafana**: Dashboards unificados correlacionando ambas fuentes de datos

## 🚀 Inicio Rápido

### 1. Prerequisitos

```powershell
# Verificar que el stack principal esté corriendo
docker-compose ps

# Si no está iniciado:
docker-compose up -d
```

### 2. Iniciar Stack de Monitoring

```powershell
# Iniciar servicios de monitoring
.\stress-testing\run-stress-tests.ps1 start

# Verificar estado
.\stress-testing\run-stress-tests.ps1 status
```

### 3. Acceder a Interfaces Web

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **Grafana** | http://localhost:3000 | admin / grafana123 |
| **Prometheus** | http://localhost:9090 | - |
| **InfluxDB** | http://localhost:8086 | admin / adminpass123 |

### 4. Ejecutar Tests

```powershell
# Smoke test (verificación básica)
.\stress-testing\run-stress-tests.ps1 test smoke

# Load test (carga normal)
.\stress-testing\run-stress-tests.ps1 test load

# Stress test (carga alta)
.\stress-testing\run-stress-tests.ps1 test stress

# Spike test (picos súbitos)
.\stress-testing\run-stress-tests.ps1 test spike

# Endurance test (resistencia - 40 min)
.\stress-testing\run-stress-tests.ps1 test endurance
```

## 📊 Tipos de Tests

### 🔍 Smoke Test
- **Duración**: 1 minuto
- **Usuarios**: 1 VU
- **Objetivo**: Verificación básica de funcionamiento
- **Thresholds**: P95 < 500ms, Error rate < 1%

### ⚡ Load Test
- **Duración**: 16 minutos
- **Usuarios**: 10-20 VUs
- **Objetivo**: Rendimiento bajo carga normal
- **Thresholds**: P95 < 800ms, Error rate < 5%

### 🔥 Stress Test
- **Duración**: 21 minutos
- **Usuarios**: 10-100 VUs
- **Objetivo**: Identificar límites del sistema
- **Thresholds**: P95 < 2000ms, Error rate < 10%

### 📈 Spike Test
- **Duración**: 6 minutos
- **Usuarios**: 10-200 VUs (picos súbitos)
- **Objetivo**: Respuesta ante incrementos repentinos
- **Thresholds**: P95 < 3000ms, Error rate < 20%

### ⏰ Endurance Test
- **Duración**: 40 minutos
- **Usuarios**: 20 VUs constantes
- **Objetivo**: Detectar memory leaks y degradación
- **Thresholds**: P95 < 1500ms, Error rate < 5%

## 📁 Estructura del Proyecto

```
stress-testing/
├── docker-compose-monitoring.yml    # Stack de monitoring
├── run-stress-tests.ps1            # Script de gestión principal
├── k6-scripts/                     # Scripts de pruebas K6
│   ├── smoke-test.js
│   ├── load-test.js
│   ├── stress-test.js
│   ├── spike-test.js
│   ├── endurance-test.js
│   └── test-suite.js
├── monitoring-config/              # Configuraciones
│   ├── prometheus.yml
│   └── grafana/
│       ├── datasources/
│       └── dashboards/
└── grafana-dashboards/             # Dashboards Grafana
    └── k6-springboot-dashboard.json
```

## 🔧 Configuración Avanzada

### Variables de Entorno K6

```bash
# InfluxDB Output
K6_OUT=influxdb=http://influxdb:8086/stress-testing-token-2025
K6_INFLUXDB_ORGANIZATION=stress-testing
K6_INFLUXDB_BUCKET=k6-metrics

# Configuración personalizada
K6_VUS=20                    # Usuarios virtuales
K6_DURATION=5m               # Duración del test
```

### Personalizar Thresholds

Edita los archivos en `k6-scripts/` para ajustar thresholds:

```javascript
export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],    // 95% < 500ms
    http_req_failed: ['rate<0.1'],       // < 10% errores
    errors: ['rate<0.1'],                // < 10% errores custom
  },
};
```

## 📈 Dashboards y Métricas

### Métricas de K6 (InfluxDB)
- `vus`: Usuarios virtuales activos
- `http_reqs`: Total de requests HTTP
- `http_req_duration`: Tiempo de respuesta
- `http_req_failed`: Tasa de errores
- `iterations`: Iteraciones completadas

### Métricas de Spring Boot (Prometheus)
- `system_cpu_usage`: Uso de CPU
- `jvm_memory_used_bytes`: Memoria JVM
- `http_server_requests_seconds`: Requests HTTP del servidor
- `application_ready_time`: Tiempo de inicio de aplicación

### Dashboard Principal
El dashboard en Grafana correlaciona métricas de ambas fuentes:
- **K6 Metrics Panel**: VUs, RPS, Error Rate, Response Time
- **Spring Boot Panel**: CPU, Memoria, Throughput
- **Correlation Panel**: Impacto de carga K6 en rendimiento Spring Boot

## 🛠️ Comandos de Gestión

```powershell
# Gestión del stack
.\run-stress-tests.ps1 start         # Iniciar monitoring
.\run-stress-tests.ps1 stop          # Detener monitoring
.\run-stress-tests.ps1 restart       # Reiniciar monitoring
.\run-stress-tests.ps1 status        # Estado de servicios
.\run-stress-tests.ps1 logs          # Ver logs

# Ejecución de tests
.\run-stress-tests.ps1 test smoke    # Test básico
.\run-stress-tests.ps1 test load     # Test de carga
.\run-stress-tests.ps1 test stress   # Test de stress
.\run-stress-tests.ps1 test spike    # Test de picos
.\run-stress-tests.ps1 test endurance # Test de resistencia
```

## 🔍 Troubleshooting

### Servicios no inician
```powershell
# Verificar logs
docker-compose -f stress-testing/docker-compose-monitoring.yml logs

# Verificar red
docker network ls | grep microservices
```

### K6 no puede conectar a servicios
```powershell
# Verificar que cloud-gateway esté disponible
curl http://localhost:8765/actuator/health

# Verificar red entre contenedores
docker network inspect java-springboot-oauth-okta-zipkin_microservices
```

### Grafana no muestra datos
1. Verificar datasources en Grafana: Settings → Data Sources
2. Revisar que InfluxDB y Prometheus estén healthy
3. Verificar buckets en InfluxDB: http://localhost:8086

### Problemas de performance durante tests
- Reducir número de VUs en scripts K6
- Incrementar recursos de Docker
- Verificar thresholds realistas

## 🎯 Objetivos de Performance

### Baseline Esperado (Sistema Optimizado)
- **Smoke Test**: 100% éxito, P95 < 300ms
- **Load Test**: 95%+ éxito, P95 < 600ms  
- **Stress Test**: 90%+ éxito, P95 < 1500ms
- **Endurance**: Sin degradación notable en 40min

### Alertas Críticas
- Error rate > 10% durante > 2min
- P95 response time > 2000ms durante > 5min
- CPU usage > 80% durante > 10min
- Memory usage > 90% durante > 5min

## 🔄 Integración CI/CD

Para integrar en pipelines CI/CD:

```yaml
# Ejemplo GitHub Actions
- name: Run Smoke Tests
  run: |
    docker-compose -f stress-testing/docker-compose-monitoring.yml up -d
    docker-compose -f stress-testing/docker-compose-monitoring.yml run --rm k6 run /scripts/smoke-test.js
    docker-compose -f stress-testing/docker-compose-monitoring.yml down
```

## 📚 Referencias

- [K6 Documentation](https://k6.io/docs/)
- [Prometheus Metrics](https://prometheus.io/docs/concepts/metric_types/)
- [InfluxDB Flux Language](https://docs.influxdata.com/flux/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)

---

**Desarrollado por**: GitHub Copilot  
**Fecha**: Julio 2025  
**Versión**: 1.0.0
