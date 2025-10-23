# Audira Platform - Microservices Architecture

Plataforma musical estilo Bandcamp construida con microservicios Spring Boot.

## Arquitectura

### Servicios de Infraestructura
- **config-server** (Puerto 8888): Servidor de configuración centralizada
- **discovery-server** (Puerto 8761): Eureka Server para registro de servicios
- **api-gateway** (Puerto 8080): Gateway de API para enrutamiento

### Microservicios de Negocio

#### ÉPICA 1: Gestión de Usuarios y Comunidad
- **user-service** (Puerto 8082): Gestión de usuarios, autenticación JWT, seguimientos
- **metrics-service** (Puerto 8081): Métricas de usuarios, artistas, canciones y globales
- **ratings-service** (Puerto 8083): Valoraciones y comentarios
- **communication-service** (Puerto 8084): Mensajes de contacto, FAQs y notificaciones

#### ÉPICA 2: Catálogo Musical (Unificado)
- **catalog-service** (Puerto 8085): Géneros, álbumes, canciones, colaboraciones y descubrimiento

#### ÉPICA 3: Reproducción y Biblioteca
- **player-service** (Puerto 8086): Reproducción, cola de reproducción e historial
- **library-service** (Puerto 8087): Biblioteca personal y colecciones
- **playlist-service** (Puerto 8088): Gestión de playlists

#### ÉPICA 4: Tienda y Comercio
- **store-service** (Puerto 8089): Productos físicos y merchandising
- **cart-service** (Puerto 8090): Carrito de compras
- **order-service** (Puerto 8091): Gestión de pedidos
- **payment-service** (Puerto 8092): Procesamiento de pagos

### Bases de Datos
Cada servicio tiene su propia base de datos PostgreSQL:
- audira_users (Puerto 5432)
- audira_metrics (Puerto 5433)
- audira_ratings (Puerto 5434)
- audira_communication (Puerto 5435)
- audira_catalog (Puerto 5436)
- audira_player (Puerto 5437)
- audira_library (Puerto 5438)
- audira_playlists (Puerto 5439)
- audira_store (Puerto 5440)
- audira_cart (Puerto 5441)
- audira_orders (Puerto 5442)
- audira_payments (Puerto 5443)

## Requisitos Previos

- Java 17+
- Maven 3.8+
- Docker y Docker Compose
- PostgreSQL 15+ (si se ejecuta localmente sin Docker)

## Instalación y Ejecución

### Opción 1: Con Docker Compose (Recomendado)

1. **Compilar todos los servicios**:
```bash
mvn clean package -DskipTests
```

2. **Iniciar todos los servicios con Docker Compose**:
```bash
docker-compose up -d
```

3. **Ver logs**:
```bash
docker-compose logs -f
```

4. **Detener todos los servicios**:
```bash
docker-compose down
```

5. **Detener y eliminar volúmenes (limpieza completa)**:
```bash
docker-compose down -v
```

### Opción 2: Ejecución Local (sin Docker)

1. **Instalar PostgreSQL 15** y crear todas las bases de datos

2. **Compilar el proyecto**:
```bash
mvn clean install
```

3. **Iniciar servicios en orden**:

```bash
# 1. Config Server
cd config-server && mvn spring-boot:run &

# 2. Discovery Server (esperar 30s)
cd discovery-server && mvn spring-boot:run &

# 3. API Gateway (esperar 30s)
cd api-gateway && mvn spring-boot:run &

# 4. Servicios de negocio (pueden iniciarse en paralelo)
cd user-service && mvn spring-boot:run &
cd metrics-service && mvn spring-boot:run &
cd ratings-service && mvn spring-boot:run &
cd communication-service && mvn spring-boot:run &
cd catalog-service && mvn spring-boot:run &
cd player-service && mvn spring-boot:run &
cd library-service && mvn spring-boot:run &
cd playlist-service && mvn spring-boot:run &
cd store-service && mvn spring-boot:run &
cd cart-service && mvn spring-boot:run &
cd order-service && mvn spring-boot:run &
cd payment-service && mvn spring-boot:run &
```

## URLs de Acceso

- **API Gateway**: http://localhost:8080
- **Eureka Dashboard**: http://localhost:8761
- **Config Server**: http://localhost:8888

### Endpoints principales (vía API Gateway)

#### Autenticación
```bash
# Registro de usuario
POST http://localhost:8080/api/users/auth/register
Content-Type: application/json
{
  "email": "user@example.com",
  "username": "usuario",
  "password": "password123",
  "firstName": "Nombre",
  "lastName": "Apellido",
  "role": "USER"
}

# Login
POST http://localhost:8080/api/users/auth/login
Content-Type: application/json
{
  "emailOrUsername": "user@example.com",
  "password": "password123"
}
```

#### Catálogo (Géneros, Álbumes, Canciones)
```bash
# Listar géneros
GET http://localhost:8080/api/genres

# Crear género
POST http://localhost:8080/api/genres

# Listar canciones
GET http://localhost:8080/api/songs

# Buscar música
GET http://localhost:8080/api/discovery/search?query=rock

# Música en tendencia
GET http://localhost:8080/api/discovery/trending
```

#### Player
```bash
# Iniciar reproducción
POST http://localhost:8080/api/player/playback/play?userId=1&songId=1

# Añadir a cola
POST http://localhost:8080/api/player/queue?userId=1&songId=2

# Ver historial
GET http://localhost:8080/api/player/history/user/1
```

#### Tienda
```bash
# Listar productos
GET http://localhost:8080/api/products

# Añadir al carrito
POST http://localhost:8080/api/cart/items?userId=1&itemType=PRODUCT&itemId=1&quantity=1

# Ver carrito
GET http://localhost:8080/api/cart/user/1

# Crear pedido
POST http://localhost:8080/api/orders
```

## Pruebas

### 1. Verificar que todos los servicios están registrados en Eureka
```bash
curl http://localhost:8761/eureka/apps
```

### 2. Healthcheck de servicios
```bash
# Config Server
curl http://localhost:8888/actuator/health

# Discovery Server
curl http://localhost:8761/actuator/health

# API Gateway
curl http://localhost:8080/actuator/health

# User Service
curl http://localhost:8082/actuator/health

# Metrics Service
curl http://localhost:8081/actuator/health
```

### 3. Prueba de flujo completo

#### a) Registrar un usuario
```bash
curl -X POST http://localhost:8080/api/users/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "artista@audira.com",
    "username": "artista1",
    "password": "password123",
    "firstName": "Juan",
    "lastName": "Pérez",
    "role": "ARTIST"
  }'
```

#### b) Login y obtener token
```bash
curl -X POST http://localhost:8080/api/users/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrUsername": "artista@audira.com",
    "password": "password123"
  }'
```

#### c) Crear un género (guarda el ID)
```bash
curl -X POST http://localhost:8080/api/genres \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Rock",
    "description": "Música Rock"
  }'
```

#### d) Crear un álbum
```bash
curl -X POST http://localhost:8080/api/albums \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mi Primer Álbum",
    "artistId": 1,
    "genreId": 1,
    "releaseDate": "2024-01-01",
    "price": 9.99,
    "description": "Un álbum increíble"
  }'
```

#### e) Crear una canción
```bash
curl -X POST http://localhost:8080/api/songs \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mi Canción",
    "artistId": 1,
    "albumId": 1,
    "genreId": 1,
    "duration": 240,
    "audioUrl": "https://example.com/song.mp3",
    "price": 0.99
  }'
```

#### f) Reproducir la canción
```bash
curl -X POST "http://localhost:8080/api/player/playback/play?userId=1&songId=1"
```

#### g) Valorar la canción
```bash
curl -X POST "http://localhost:8080/api/ratings?userId=1&entityType=SONG&entityId=1&rating=5"
```

#### h) Comentar la canción
```bash
curl -X POST "http://localhost:8080/api/comments?userId=1&entityType=SONG&entityId=1&content=Excelente+canción"
```

#### i) Ver métricas de la canción
```bash
curl http://localhost:8080/api/metrics/songs/1
```

### 4. Prueba de Tienda

#### a) Crear producto
```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "artistId": 1,
    "name": "Camiseta del Tour",
    "description": "Camiseta oficial",
    "price": 25.00,
    "stock": 100,
    "category": "Ropa"
  }'
```

#### b) Añadir al carrito
```bash
curl -X POST "http://localhost:8080/api/cart/items?userId=1&itemType=PRODUCT&itemId=1&quantity=2"
```

#### c) Ver carrito
```bash
curl http://localhost:8080/api/cart/user/1
```

#### d) Crear pedido
```bash
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "items": [
      {
        "itemType": "PRODUCT",
        "itemId": 1,
        "quantity": 2,
        "price": 25.00
      }
    ],
    "totalAmount": 50.00,
    "shippingAddress": "Calle Principal 123"
  }'
```

## Monitoreo

Todos los servicios incluyen Spring Boot Actuator con endpoints de monitoreo:

```bash
# Health check
curl http://localhost:<PORT>/actuator/health

# Métricas
curl http://localhost:<PORT>/actuator/metrics

# Info
curl http://localhost:<PORT>/actuator/info
```

## Tecnologías Utilizadas

- **Spring Boot 3.2.0**: Framework principal
- **Spring Cloud 2023.0.0**: Infraestructura de microservicios
- **Spring Cloud Netflix Eureka**: Service Discovery
- **Spring Cloud Gateway**: API Gateway
- **Spring Cloud Config**: Configuración centralizada
- **Spring Security + JWT**: Autenticación y autorización
- **Spring Data JPA**: Persistencia de datos
- **PostgreSQL 15**: Base de datos relacional
- **Lombok**: Reducción de código boilerplate
- **Docker**: Contenedorización
- **Maven**: Gestión de dependencias y build

## Estructura del Proyecto

```
audira/
├── pom.xml                      # Parent POM
├── docker-compose.yml           # Orquestación Docker
├── README.md                    # Este archivo
├── config-server/               # Servidor de configuración
├── discovery-server/            # Eureka Server
├── api-gateway/                 # API Gateway
├── user-service/                # Gestión de usuarios
├── metrics-service/             # Métricas
├── ratings-service/             # Valoraciones
├── communication-service/       # Comunicación
├── catalog-service/             # Catálogo musical
├── player-service/              # Reproductor
├── library-service/             # Biblioteca
├── playlist-service/            # Playlists
├── store-service/               # Tienda
├── cart-service/                # Carrito
├── order-service/               # Pedidos
└── payment-service/             # Pagos
```

## Troubleshooting

### Los servicios no se registran en Eureka
- Verificar que discovery-server esté ejecutándose
- Esperar 30-60 segundos para el registro automático
- Verificar logs: `docker-compose logs discovery-server`

### Error de conexión a base de datos
- Verificar que PostgreSQL esté ejecutándose
- Verificar credenciales en application.yml
- Con Docker: `docker-compose ps` para ver el estado

### Errores de compilación
- Verificar versión de Java: `java -version` (debe ser 17+)
- Limpiar y recompilar: `mvn clean install -U`

### Puerto ya en uso
- Cambiar el puerto en application.yml del servicio
- Matar proceso: `lsof -ti:PUERTO | xargs kill -9`

## Licencia

Este proyecto es parte de una aplicación de ejemplo educativa.

## Autor

Desarrollado para la plataforma Audira
