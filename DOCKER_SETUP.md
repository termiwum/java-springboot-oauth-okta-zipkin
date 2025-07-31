# 🐳 Docker Setup - Ecosistema de Microservicios

Este documento contiene todas las configuraciones necesarias para levantar el ecosistema completo de microservicios usando Docker con networking adecuado.

## 📋 Prerrequisitos

- Docker Desktop instalado y corriendo
- Git configurado
- Puertos disponibles: 3307-3309, 6379, 8761, 9090, 9296, 9411

## 🚀 Configuración Paso a Paso

### 1. 🌐 Crear Red de Docker

Primero, crear la red personalizada para que todos los servicios se comuniquen entre sí:

```bash
docker network create microservices-network
```

### 2. 🗄️ Levantar Bases de Datos MySQL

Crear las bases de datos MySQL para cada microservicio:

```bash
# MySQL para Product Service
docker run -d --name mysql-product --network microservices-network \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=product_db \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=admin \
  -p 3307:3306 \
  mysql:8.0

# MySQL para Payment Service
docker run -d --name mysql-payment --network microservices-network \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=payment_db \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=admin \
  -p 3308:3306 \
  mysql:8.0

# MySQL para Order Service
docker run -d --name mysql-order --network microservices-network \
  -e MYSQL_ROOT_PASSWORD=admin \
  -e MYSQL_DATABASE=order_db \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=admin \
  -p 3309:3306 \
  mysql:8.0
```

### 3. 📊 Levantar Servicios de Infraestructura

#### Redis (Cache)
```bash
docker run -d --name redis --network microservices-network \
  -p 6379:6379 \
  redis:alpine
```

#### Zipkin (Tracing distribuido)
```bash
docker run -d --name zipkin --network microservices-network \
  -p 9411:9411 \
  openzipkin/zipkin
```

### 4. 🏗️ Construir Imágenes de los Microservicios

Desde el directorio raíz del proyecto, construir cada microservicio:

```bash
# Service Registry (Eureka)
cd service-registry
./mvnw clean package -DskipTests
docker build -t service-registry .
cd ..

# Config Server
cd config-server
./mvnw clean package -DskipTests
docker build -t config-server .
cd ..

# Product Service
cd product-service
./mvnw clean package -DskipTests
docker build -t product-service .
cd ..

# Payment Service
cd payment-service
./mvnw clean package -DskipTests
docker build -t payment-service .
cd ..

# Order Service
cd order-service
./mvnw clean package -DskipTests
docker build -t order-service .
cd ..

# Cloud Gateway
cd cloud-gateway
./mvnw clean package -DskipTests
docker build -t cloud-gateway .
cd ..
```

### 5. 🚀 Levantar Microservicios

#### Service Registry (Eureka)
```bash
docker run -d --name service-registry --network microservices-network \
  -p 8761:8761 \
  service-registry
```

#### Config Server
```bash
docker run -d --name config-server --network microservices-network \
  -p 9296:9296 \
  -e EUREKA_HOST=service-registry \
  config-server
```

#### Servicios de Negocio
```bash
# Product Service
docker run -d --name product-service --network microservices-network \
  -e EUREKA_HOST=service-registry \
  -e CONFIG_SERVER_HOST=config-server \
  -e ZIPKIN_HOST=zipkin \
  -e DB_HOST=mysql-product \
  product-service

# Payment Service
docker run -d --name payment-service --network microservices-network \
  -e EUREKA_HOST=service-registry \
  -e CONFIG_SERVER_HOST=config-server \
  -e ZIPKIN_HOST=zipkin \
  -e DB_HOST=mysql-payment \
  payment-service

# Order Service
docker run -d --name order-service --network microservices-network \
  -e EUREKA_HOST=service-registry \
  -e CONFIG_SERVER_HOST=config-server \
  -e ZIPKIN_HOST=zipkin \
  -e DB_HOST=mysql-order \
  order-service
```

#### API Gateway
```bash
docker run -d --name cloud-gateway --network microservices-network \
  -p 9090:9090 \
  -e EUREKA_HOST=service-registry \
  -e CONFIG_SERVER_HOST=config-server \
  -e ZIPKIN_HOST=zipkin \
  cloud-gateway
```

## 🔍 Verificación del Ecosistema

### Verificar que todos los contenedores estén corriendo:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Acceder a los servicios:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Eureka Dashboard** | http://localhost:8761 | Registry de servicios |
| **Config Server** | http://localhost:9296 | Servidor de configuración |
| **API Gateway** | http://localhost:9090 | Punto de entrada principal |
| **Zipkin UI** | http://localhost:9411 | Trazas distribuidas |
| **Redis** | localhost:6379 | Cache |

### Verificar registro en Eureka:
1. Abrir http://localhost:8761
2. Verificar que aparezcan todos los servicios:
   - API-GATEWAY
   - CONFIG-SERVER
   - ORDER-SERVICE
   - PAYMENT-SERVICE
   - PRODUCT-SERVICE

## 🛠️ Variables de Entorno Utilizadas

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `EUREKA_HOST` | Host del Service Registry | localhost |
| `CONFIG_SERVER_HOST` | Host del Config Server | localhost |
| `ZIPKIN_HOST` | Host de Zipkin para tracing | localhost |
| `DB_HOST` | Host de la base de datos MySQL | localhost |

## 🐞 Troubleshooting

### Problema: Servicios no se registran en Eureka
```bash
# Verificar logs del servicio
docker logs <service-name> --tail 50

# Verificar conectividad de red
docker exec <service-name> ping service-registry
```

### Problema: Error de conexión a base de datos
```bash
# Verificar que MySQL esté corriendo
docker logs mysql-<service> --tail 20

# Verificar conectividad
docker exec <service-name> ping mysql-<service>
```

### Problema: Config Server no responde
```bash
# Verificar logs del config server
docker logs config-server --tail 50

# Verificar que el repositorio GitHub sea accesible
curl http://localhost:9296/actuator/health
```

## 🧹 Limpieza del Entorno

Para detener y eliminar todo el ecosistema:

```bash
# Detener todos los contenedores
docker stop $(docker ps -q --filter "network=microservices-network")

# Eliminar todos los contenedores
docker rm $(docker ps -aq --filter "network=microservices-network")

# Eliminar la red
docker network rm microservices-network

# Eliminar imágenes (opcional)
docker rmi service-registry config-server product-service payment-service order-service cloud-gateway
```

## 📊 Monitoreo y Logs

### Ver logs en tiempo real:
```bash
# Logs de un servicio específico
docker logs -f <service-name>

# Logs de todos los servicios de negocio
docker logs -f product-service &
docker logs -f payment-service &
docker logs -f order-service &
```

### Verificar salud de servicios:
```bash
# Health check del Config Server
curl http://localhost:9296/actuator/health

# Health check a través del Gateway
curl http://localhost:9090/actuator/health
```

## 🎯 Orden de Arranque Recomendado

1. **Infraestructura**: Redis, Zipkin, MySQL
2. **Service Registry**: Eureka
3. **Config Server**: Configuración centralizada
4. **Servicios de Negocio**: Product, Payment, Order
5. **API Gateway**: Último para asegurar que todos los servicios estén registrados

---

## 🎉 ¡Ecosistema Completamente Operativo!

Una vez completados todos los pasos, tendrás un ecosistema completo de microservicios con:

- ✅ **Service Discovery** con Eureka
- ✅ **Configuración Centralizada** con Config Server
- ✅ **API Gateway** con routing y load balancing
- ✅ **Trazas Distribuidas** con Zipkin
- ✅ **Cache Redis**
- ✅ **Bases de Datos MySQL** independientes
- ✅ **Networking Docker** para comunicación interna
- ✅ **OAuth2/JWT** para seguridad
- ✅ **Circuit Breakers** para resiliencia

**Punto de entrada principal**: http://localhost:9090
