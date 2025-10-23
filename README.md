# Audira Platform - Epic-Based Microservices Architecture

Plataforma musical estilo Bandcamp construida con microservicios Spring Boot organizados por épicas funcionales.

## Arquitectura

### Servicios de Infraestructura
- **config-server** (Puerto 8888): Servidor de configuración centralizada
- **discovery-server** (Puerto 8761): Eureka Server para registro de servicios
- **api-gateway** (Puerto 8080): Gateway de API para enrutamiento

### Microservicios de Negocio (Organizados por Épicas)

#### ÉPICA 1: Community Service (Puerto 8081)
**Responsabilidades**: Gestión de usuarios, autenticación, métricas, valoraciones y comunicación
- **Módulos consolidados**:
  - Users: Gestión de usuarios con herencia (RegularUser, Artist, Admin)
  - Authentication: JWT, registro y login
  - Metrics: Métricas de usuarios, artistas, canciones y globales
  - Ratings: Valoraciones y comentarios
  - Communication: Mensajes de contacto, FAQs y notificaciones
- **Modelos principales**:
  - User (abstract) → RegularUser, Artist, Admin
  - UserMetrics, ArtistMetrics, SongMetrics, GlobalMetrics
  - Rating, Comment
  - ContactMessage, FAQ, Notification

#### ÉPICA 2: Music Catalog Service (Puerto 8082)
**Responsabilidades**: Catálogo completo de música (géneros, álbumes, canciones, colaboraciones)
- **Módulos consolidados**:
  - Genres: Gestión de géneros musicales
  - Albums: Álbumes con precio calculado automáticamente (suma de canciones - 15%)
  - Songs: Canciones con múltiples géneros, contador de reproducciones
  - Collaborators: Sistema avanzado de colaboraciones (artista principal, featured, productor, etc.)
  - Discovery: Búsqueda y descubrimiento de música
- **Modelos principales**:
  - Product (abstract) → Song, Album
  - Genre
  - Collaborator (reemplaza Collaboration)
- **Características**:
  - Soporte para múltiples géneros por canción/álbum
  - Precio de álbum auto-calculado con 15% descuento
  - Sistema de colaboradores con tipos específicos

#### ÉPICA 3: Playback Service (Puerto 8083)
**Responsabilidades**: Reproducción de música, biblioteca personal y playlists
- **Módulos consolidados**:
  - Playback: Sesiones de reproducción, control de player
  - Queue: Cola de reproducción con modos (shuffle, repeat)
  - History: Historial de reproducciones
  - Library: Biblioteca personal del usuario
  - Collections: Colecciones personalizadas
  - Playlists: Gestión completa de playlists
- **Modelos principales**:
  - PlaybackSession, PlayQueue, PlayHistory
  - LibraryItem, Collection
  - Playlist, PlaylistSong

#### ÉPICA 4: Commerce Service (Puerto 8084)
**Responsabilidades**: Tienda, carrito, pedidos y pagos
- **Módulos consolidados**:
  - Store: Productos físicos y merchandising
  - Cart: Carrito de compras unificado (canciones, álbumes, productos)
  - Orders: Gestión completa de pedidos
  - Payments: Procesamiento de pagos con webhooks
- **Modelos principales**:
  - Product, ProductVariant
  - Cart, CartItem
  - Order, OrderItem (con ItemType enum: SONG, ALBUM, MERCHANDISE, TICKET, SUBSCRIPTION)
  - Payment

### Bases de Datos
Cada servicio épico tiene su propia base de datos PostgreSQL:
- **audira_community** (Puerto 5432): Users, Metrics, Ratings, Communication
- **audira_catalog** (Puerto 5433): Genres, Albums, Songs, Collaborators
- **audira_playback** (Puerto 5434): Playback, Library, Playlists
- **audira_commerce** (Puerto 5435): Store, Cart, Orders, Payments

## Cambios Arquitectónicos Importantes

### Consolidación de Servicios
- **11 microservicios → 4 servicios épicos**: Reducción de complejidad operacional
- **12 bases de datos → 4 bases de datos**: Simplificación de infraestructura
- **Mejor cohesión funcional**: Los módulos relacionados están juntos

### Modelos con Herencia
- **User**: Clase abstracta con subtipos RegularUser, Artist, Admin
- **Product**: Clase abstracta con subtipos Song, Album
- **Estrategia JPA**: InheritanceType.JOINED para mejor normalización

### Mejoras en el Modelo de Datos
- **Múltiples géneros**: Songs y Albums soportan Set<Long> genreIds
- **Precio de álbum auto-calculado**: 15% descuento sobre suma de canciones
- **Collaborator**: Reemplaza Collaboration con tipos específicos (MAIN_ARTIST, FEATURED_ARTIST, PRODUCER, etc.)
- **Contador de reproducciones**: Campo `plays` en Song
- **Track numbers**: Campo `trackNumber` para ordenar canciones en álbum
- **Firebase UID**: Campo `uid` en User (TODO: migrar autenticación a Firebase)

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

1. **Instalar PostgreSQL 15** y crear las 4 bases de datos

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

# 4. Servicios épicos (pueden iniciarse en paralelo)
cd community-service && mvn spring-boot:run &
cd music-catalog-service && mvn spring-boot:run &
cd playback-service && mvn spring-boot:run &
cd commerce-service && mvn spring-boot:run &
```

## URLs de Acceso

- **API Gateway**: http://localhost:8080
- **Eureka Dashboard**: http://localhost:8761
- **Config Server**: http://localhost:8888

### Endpoints principales (vía API Gateway)

#### ÉPICA 1: Community Service - Autenticación y Usuarios

```bash
# Registro de usuario
POST http://localhost:8080/api/users/auth/register
Content-Type: application/json
{
  "email": "user@example.com",
  "username": "usuario",
  "password": "Password123!",
  "firstName": "Nombre",
  "lastName": "Apellido",
  "role": "USER"  // USER, ARTIST, ADMIN
}

# Login
POST http://localhost:8080/api/users/auth/login
Content-Type: application/json
{
  "emailOrUsername": "user@example.com",
  "password": "Password123!"
}

# Ver perfil actual (requiere JWT)
GET http://localhost:8080/api/users/profile
Authorization: Bearer {token}

# Ver perfil de otro usuario
GET http://localhost:8080/api/users/{id}

# Actualizar perfil
PUT http://localhost:8080/api/users/profile
Authorization: Bearer {token}
```

#### Community Service - Métricas

```bash
# Métricas de usuario
GET http://localhost:8080/api/metrics/users/{userId}

# Métricas de artista
GET http://localhost:8080/api/metrics/artists/{artistId}

# Métricas de canción
GET http://localhost:8080/api/metrics/songs/{songId}

# Métricas globales
GET http://localhost:8080/api/metrics/global
```

#### Community Service - Valoraciones y Comentarios

```bash
# Crear valoración
POST http://localhost:8080/api/ratings
{
  "userId": 1,
  "entityType": "SONG",  // SONG, ALBUM, PRODUCT
  "entityId": 1,
  "rating": 5
}

# Crear comentario
POST http://localhost:8080/api/comments
{
  "userId": 1,
  "entityType": "SONG",
  "entityId": 1,
  "content": "Excelente canción!"
}

# Ver valoraciones por entidad
GET http://localhost:8080/api/ratings/entity/{entityType}/{entityId}

# Ver comentarios
GET http://localhost:8080/api/comments/entity/{entityType}/{entityId}
```

#### ÉPICA 2: Music Catalog Service

```bash
# Listar géneros
GET http://localhost:8080/api/genres

# Crear género
POST http://localhost:8080/api/genres
{
  "name": "Rock",
  "description": "Rock music genre",
  "imageUrl": "https://example.com/rock.jpg"
}

# Listar canciones
GET http://localhost:8080/api/songs

# Crear canción (con múltiples géneros)
POST http://localhost:8080/api/songs
{
  "title": "Mi Canción",
  "artistId": 1,
  "albumId": 1,
  "genreIds": [1, 2, 3],  // Múltiples géneros
  "duration": 240,
  "audioUrl": "https://example.com/song.mp3",
  "price": 0.99,
  "lyrics": "Letra de la canción",
  "trackNumber": 1
}

# Crear álbum (precio auto-calculado)
POST http://localhost:8080/api/albums
{
  "title": "Mi Álbum",
  "artistId": 1,
  "genreIds": [1, 2],
  "releaseDate": "2024-01-01",
  "description": "Descripción del álbum"
}

# Añadir colaborador a canción
POST http://localhost:8080/api/collaborations
{
  "songId": 1,
  "artistId": 2,
  "artistName": "Artista Colaborador",
  "collaborationType": "FEATURED_ARTIST"
  // Tipos: MAIN_ARTIST, FEATURED_ARTIST, PRODUCER, COMPOSER, LYRICIST, etc.
}

# Buscar música
GET http://localhost:8080/api/discovery/search?query=rock

# Música en tendencia
GET http://localhost:8080/api/discovery/trending
```

#### ÉPICA 3: Playback Service

```bash
# Iniciar reproducción
POST http://localhost:8080/api/playback/play?userId=1&songId=1

# Pausar
POST http://localhost:8080/api/playback/pause?userId=1

# Siguiente canción
POST http://localhost:8080/api/playback/next?userId=1

# Añadir a cola
POST http://localhost:8080/api/queue?userId=1&songId=2

# Ver cola
GET http://localhost:8080/api/queue/{userId}

# Ver historial
GET http://localhost:8080/api/history/user/{userId}

# Ver biblioteca del usuario
GET http://localhost:8080/api/library/{userId}

# Crear playlist
POST http://localhost:8080/api/playlists
{
  "userId": 1,
  "name": "Mi Playlist",
  "description": "Descripción",
  "isPublic": true
}

# Añadir canción a playlist
POST http://localhost:8080/api/playlists/{playlistId}/songs
{
  "songId": 1
}
```

#### ÉPICA 4: Commerce Service

```bash
# Listar productos
GET http://localhost:8080/api/products

# Crear producto
POST http://localhost:8080/api/products
{
  "artistId": 1,
  "name": "Camiseta del Tour",
  "description": "Camiseta oficial",
  "category": "CLOTHING",
  "price": 25.00,
  "stock": 100,
  "imageUrls": ["https://example.com/shirt.jpg"]
}

# Ver carrito
GET http://localhost:8080/api/cart/{userId}

# Añadir al carrito
POST http://localhost:8080/api/cart/items
{
  "userId": 1,
  "itemType": "SONG",  // SONG, ALBUM, MERCHANDISE, TICKET, SUBSCRIPTION
  "itemId": 1,
  "quantity": 1,
  "price": 0.99
}

# Crear pedido
POST http://localhost:8080/api/orders
{
  "userId": 1,
  "items": [
    {
      "itemType": "SONG",
      "itemId": 1,
      "quantity": 1,
      "price": 0.99
    }
  ],
  "totalAmount": 0.99,
  "shippingAddress": "Calle Principal 123"
}

# Ver pedidos del usuario
GET http://localhost:8080/api/orders/user/{userId}

# Procesar pago
POST http://localhost:8080/api/payments
{
  "orderId": 1,
  "amount": 0.99,
  "paymentMethod": "CREDIT_CARD"
}
```

## Pruebas Automatizadas

### Script de pruebas Bash (Linux/Mac)
```bash
chmod +x test-epic-services.sh
./test-epic-services.sh
```

### Script de pruebas PowerShell (Windows)
```powershell
.\test-all-services.ps1
```

Ambos scripts prueban:
- Infraestructura (Config Server, Eureka, API Gateway)
- ÉPICA 1: Community Service (Registro, Login, Perfil, Métricas, Valoraciones)
- ÉPICA 2: Music Catalog (Géneros, Canciones, Álbumes, Colaboraciones)
- ÉPICA 3: Playback (Playlists, Biblioteca, Reproducción)
- ÉPICA 4: Commerce (Productos, Carrito, Pedidos, Pagos)

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
- **Spring Cloud Gateway**: API Gateway con predicados por ruta
- **Spring Cloud Config**: Configuración centralizada
- **Spring Security + JWT**: Autenticación y autorización
- **Spring Data JPA**: Persistencia con herencia de entidades
- **PostgreSQL 15**: Base de datos relacional
- **Lombok**: Reducción de código boilerplate
- **Docker**: Contenedorización
- **Maven**: Gestión de dependencias y build multi-módulo

## Estructura del Proyecto

```
audira/
├── pom.xml                      # Parent POM
├── docker-compose.yml           # Orquestación Docker
├── README.md                    # Este archivo
├── test-epic-services.sh        # Script de pruebas (Bash)
├── test-all-services.ps1        # Script de pruebas (PowerShell)
├── config-server/               # Servidor de configuración
├── discovery-server/            # Eureka Server
├── api-gateway/                 # API Gateway
├── community-service/           # ÉPICA 1: Users, Metrics, Ratings, Communication
│   ├── src/main/java/io/audira/community/
│   │   ├── model/              # User (abstract), RegularUser, Artist, Admin
│   │   ├── controller/         # AuthController, UserController, MetricsController, etc.
│   │   ├── service/            # UserService, MetricsService, RatingService, etc.
│   │   └── repository/         # JPA Repositories
│   └── src/main/resources/
│       └── application.yml
├── music-catalog-service/       # ÉPICA 2: Genres, Albums, Songs, Collaborators
│   ├── src/main/java/io/audira/catalog/
│   │   ├── model/              # Product (abstract), Song, Album, Genre, Collaborator
│   │   ├── controller/         # GenreController, SongController, AlbumController, etc.
│   │   ├── service/            # AlbumService (auto-precio), SongService, etc.
│   │   └── repository/         # JPA Repositories
│   └── src/main/resources/
│       └── application.yml
├── playback-service/            # ÉPICA 3: Playback, Library, Playlists
│   ├── src/main/java/io/audira/playback/
│   │   ├── model/              # PlaybackSession, PlayQueue, Playlist, LibraryItem
│   │   ├── controller/         # PlaybackController, QueueController, etc.
│   │   ├── service/            # PlaybackService, PlaylistService, LibraryService
│   │   └── repository/         # JPA Repositories
│   └── src/main/resources/
│       └── application.yml
└── commerce-service/            # ÉPICA 4: Store, Cart, Orders, Payments
    ├── src/main/java/io/audira/commerce/
    │   ├── model/              # Product, Cart, Order, Payment, ItemType enum
    │   ├── controller/         # ProductController, CartController, OrderController
    │   ├── service/            # ProductService, CartService, OrderService, PaymentService
    │   └── repository/         # JPA Repositories
    └── src/main/resources/
        └── application.yml
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

## Roadmap

### Próximas mejoras
- [ ] Migrar autenticación a Firebase (remover campo password de User)
- [ ] Implementar caching con Redis
- [ ] Agregar mensajería asíncrona con RabbitMQ/Kafka
- [ ] Circuit breakers con Resilience4j
- [ ] API rate limiting
- [ ] Distributed tracing con Zipkin
- [ ] Centralización de logs con ELK stack

## Licencia

Este proyecto es parte de una aplicación de ejemplo educativa.

## Autor

Desarrollado para la plataforma Audira
