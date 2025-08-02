# 📊 Stress Testing & Microservices Monitoring Guide

## 🌟 Overview

Este sistema de stress testing proporciona una suite completa para monitorear y evaluar el rendimiento de un ecosistema de microservicios Spring Boot con autenticación OAuth2 (Auth0) integrada. Incluye pruebas específicas para cada servicio y monitoreo en tiempo real.

## 🎯 Testing Suite Components

### 📋 Test Files
- **ecosystem-global-test.js**: Pruebas comprehensivas del ecosistema completo
- **order-place-test.js**: Pruebas de creación de órdenes con cadena de servicios
- **order-details-test.js**: Pruebas de consulta de detalles de órdenes
- **payment-service-test.js**: Pruebas de procesamiento y consulta de pagos
- **product-service-test.js**: Pruebas CRUD completas del servicio de productos

### 📊 Dashboard Collection
- **ecosystem-global-dashboard.json**: Vista general del ecosistema
- **order-place-dashboard.json**: Monitoreo específico de creación de órdenes
- **order-details-dashboard.json**: Dashboard para consultas de órdenes
- **payment-service-dashboard.json**: Métricas del servicio de pagos
- **product-service-dashboard.json**: Dashboard del servicio de productos

### 🚀 Automated Execution Scripts
- **run-automated-tests.ps1**: Script para Windows (PowerShell)
- **run-automated-tests.sh**: Script para Linux/macOS (Bash)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   K6 Testing    │────│   Auth0 OAuth   │────│  Spring Boot    │
│     Engine      │    │   Integration   │    │  Microservices  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
    │   InfluxDB      │────│    Grafana      │────│   Real-time     │
    │   Metrics       │    │   Dashboards    │    │   Monitoring    │
    │   Storage       │    │                 │    │                 │
    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Setup Instructions

### Prerequisites
- K6 installed (`k6 version`)
- Docker and Docker Compose
- Auth0 credentials configured

### 1. Configure Authentication

Create authentication configuration file:
```bash
# Copy the template
cp oauth2-auth.js.example oauth2-auth.js

# Edit with your Auth0 credentials
# Note: This file is protected by .gitignore
```

### 2. Start Monitoring Stack

```bash
# Start InfluxDB and Grafana
docker-compose -f docker-compose-monitoring.yml up -d

# Verify services
docker ps
```

### 3. Import Grafana Dashboards

```bash
# Access Grafana at http://localhost:3000
# Default credentials: admin/admin

# Import dashboards from:
# - grafana-dashboards/ecosystem-global-dashboard.json
# - grafana-dashboards/order-place-dashboard.json
# - grafana-dashboards/order-details-dashboard.json
# - grafana-dashboards/payment-service-dashboard.json
# - grafana-dashboards/product-service-dashboard.json
```

## 🎮 Test Execution

### Option 1: Individual Tests
```bash
# Run specific test
k6 run ecosystem-global-test.js
k6 run order-place-test.js
k6 run order-details-test.js
k6 run payment-service-test.js
k6 run product-service-test.js
```

### Option 2: Automated Execution

#### Windows (PowerShell)
```powershell
# Run all tests sequentially
.\run-automated-tests.ps1 -Mode Sequential

# Run tests in parallel
.\run-automated-tests.ps1 -Mode Parallel

# Run global ecosystem test only
.\run-automated-tests.ps1 -Mode Global

# Run specific test
.\run-automated-tests.ps1 -Mode Individual -TestName order-place-test.js
```

#### Linux/macOS (Bash)
```bash
# Make script executable
chmod +x run-automated-tests.sh

# Run all tests sequentially
./run-automated-tests.sh sequential

# Run tests in parallel
./run-automated-tests.sh parallel

# Run global ecosystem test only
./run-automated-tests.sh global

# Run specific test
./run-automated-tests.sh individual order-place-test.js
```

## 📊 Metrics & Monitoring

### Key Metrics Tracked
- **Response Times**: Average, P90, P95 percentiles
- **Error Rates**: HTTP errors, service failures
- **Request Rates**: Requests per second by service
- **Service Availability**: Uptime percentage
- **Business Operations**: Order creation, payment processing, product operations

### Dashboard Overview

#### 🌐 Ecosystem Global Dashboard
- System-wide availability and health
- Service response time comparisons
- Global error rate monitoring
- Request distribution by scenario

#### 📦 Order Service Dashboards
- Order creation flow monitoring
- Service chain communication timing
- Order details retrieval performance
- Success rate tracking

#### 💳 Payment Service Dashboard
- Payment processing metrics
- Transaction query performance
- Operation distribution analysis
- Error rate monitoring

#### 🛍️ Product Service Dashboard
- CRUD operation performance
- Inventory update tracking
- Product creation metrics
- Service availability monitoring

## 🔒 Security Considerations

### Authentication Flow
1. OAuth2 Client Credentials flow with Auth0
2. Token caching mechanism for performance
3. Automatic token refresh handling
4. Secure credential storage (.gitignore protection)

### Best Practices
- Credentials stored in ignored configuration files
- Template files provided for setup guidance
- Environment-specific configuration support
- Rate limiting awareness in test design

## 🚨 Troubleshooting

### Common Issues

#### Authentication Failures
```bash
# Check Auth0 configuration
cat oauth2-auth.js.example
# Verify domain and credentials
```

#### Dashboard Connection Issues
```bash
# Check InfluxDB status
docker logs influxdb

# Verify Grafana datasource
# Check IP address in datasource configuration: http://172.17.0.1:8086
```

#### Service Connectivity
```bash
# Test individual service endpoints
curl -X GET "http://localhost:8082/api/orders"
```

### Monitoring Stack Issues
```bash
# Restart monitoring services
docker-compose -f docker-compose-monitoring.yml restart

# Check container logs
docker logs grafana
docker logs influxdb
```

## 📈 Performance Tuning

### Test Configuration
- Adjust VU (Virtual Users) count based on system capacity
- Modify duration settings for longer stress tests
- Configure scenario weights for realistic load distribution

### System Resources
- Monitor CPU and memory usage during tests
- Adjust Docker container resources if needed
- Consider horizontal scaling for higher loads

## 🎯 Test Scenarios

### Load Testing Profiles
1. **Light Load**: 5-10 VUs, 2-5 minutes
2. **Normal Load**: 20-50 VUs, 10-15 minutes
3. **Stress Test**: 100+ VUs, 15-30 minutes
4. **Spike Test**: Variable VU ramp-up/down patterns

### Business Scenarios
- **Order Processing**: Complete order lifecycle
- **Product Management**: CRUD operations with inventory
- **Payment Processing**: Transaction creation and queries
- **Mixed Workload**: Realistic user behavior simulation

## 🔍 Analysis Guidelines

### Key Performance Indicators
- **Response Time**: < 1000ms for 95% of requests
- **Error Rate**: < 1% under normal load
- **Throughput**: Target requests per second by service
- **Availability**: > 99.9% uptime during testing

### Bottleneck Identification
- Service-specific response time analysis
- Database query performance review
- Network latency assessment
- Resource utilization correlation

## 📝 Reporting

### Automated Reports
- Test execution summaries in terminal output
- Real-time metrics in Grafana dashboards
- Historical data analysis capabilities
- Performance trend identification

### Manual Analysis
- Dashboard screenshot capture for reports
- Metric export from InfluxDB for detailed analysis
- Performance comparison across test runs
- Capacity planning recommendations

---

## 🏆 Success Criteria

✅ **System Availability**: > 99% uptime during testing  
✅ **Response Performance**: P95 < 2000ms  
✅ **Error Tolerance**: < 5% error rate under stress  
✅ **Scalability**: Linear performance degradation under load  
✅ **Security**: Successful OAuth2 integration across all services

---

*Esta documentación proporciona una guía completa para ejecutar y monitorear el sistema de stress testing del ecosistema de microservicios.*
