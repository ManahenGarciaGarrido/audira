# Audira Backend API

Backend API para la plataforma Audira - ÉPICA 1: Gestión de Usuarios y Comunidad

## Descripción

Este es el backend de la aplicación Audira, una plataforma tipo Bandcamp para música. Esta implementación incluye todos los endpoints necesarios para la gestión de usuarios, métricas, valoraciones, comentarios y comunicación.

## Características

- 🔐 Autenticación JWT
- 👥 Gestión completa de usuarios (registro, login, perfil, seguidores)
- 📊 Sistema de métricas (usuarios, artistas, canciones, globales)
- ⭐ Valoraciones y comentarios de productos
- 💬 Sistema de comunicación (contacto, FAQs, notificaciones)
- 🛡️ Seguridad con Helmet
- ✅ Validación de datos con express-validator
- 📝 Documentación completa de API según OpenAPI 3.1

## Requisitos

- Node.js >= 18.x
- npm >= 9.x

## Instalación

```bash
# Navegar al directorio del backend
cd backend

# Instalar dependencias
npm install

# Copiar archivo de variables de entorno
cp .env.example .env

# Editar .env con tus configuraciones
nano .env
```

## Variables de Entorno

Crea un archivo `.env` en la raíz del directorio backend:

```env
PORT=3000
NODE_ENV=development
JWT_SECRET=tu-clave-secreta-super-segura
JWT_EXPIRES_IN=3600
CORS_ORIGIN=http://localhost:*
```

## Scripts Disponibles

```bash
# Modo desarrollo con auto-reload
npm run dev

# Compilar TypeScript a JavaScript
npm run build

# Ejecutar en producción
npm start

# Ejecutar tests
npm test
```

## Estructura del Proyecto

```
backend/
├── src/
│   ├── controllers/       # Controladores de la lógica de negocio
│   ├── middleware/        # Middlewares (auth, validación, errores)
│   ├── models/           # Modelos de datos y almacenamiento
│   ├── routes/           # Definición de rutas
│   ├── types/            # Tipos TypeScript
│   ├── utils/            # Utilidades (JWT, errores)
│   └── index.ts          # Punto de entrada del servidor
├── dist/                 # Código compilado (generado)
├── package.json
├── tsconfig.json
└── README.md
```

## Endpoints Principales

### Usuarios
- `POST /api/v1/users/register` - Registrar nuevo usuario
- `POST /api/v1/users/login` - Iniciar sesión
- `POST /api/v1/users/logout` - Cerrar sesión
- `GET /api/v1/users/:id` - Obtener perfil de usuario
- `PUT /api/v1/users/:id` - Actualizar perfil
- `DELETE /api/v1/users/:id` - Eliminar cuenta
- `GET /api/v1/users/:id/followers` - Listar seguidores
- `GET /api/v1/users/:id/following` - Listar seguidos

### Métricas
- `GET /api/v1/metrics/user/:id` - Métricas de usuario
- `GET /api/v1/metrics/artist/:id` - Métricas de artista
- `GET /api/v1/metrics/song/:id` - Métricas de canción
- `GET /api/v1/metrics/global` - Métricas globales

### Valoraciones
- `POST /api/v1/ratings` - Crear valoración
- `PUT /api/v1/ratings/:id` - Actualizar valoración
- `DELETE /api/v1/ratings/:id` - Eliminar valoración
- `GET /api/v1/ratings/product/:productId` - Obtener valoraciones de producto

### Comentarios
- `POST /api/v1/comments` - Crear comentario
- `PUT /api/v1/comments/:id` - Actualizar comentario
- `DELETE /api/v1/comments/:id` - Eliminar comentario
- `GET /api/v1/comments/product/:productId` - Obtener comentarios de producto

### Comunicación
- `POST /api/v1/contact/messages` - Enviar mensaje de contacto
- `GET /api/v1/contact/faqs` - Obtener FAQs
- `GET /api/v1/contact/notifications/:userId` - Obtener notificaciones

## Autenticación

La API utiliza JWT (JSON Web Tokens) para la autenticación. Después de iniciar sesión, incluye el token en el header de autorización:

```
Authorization: Bearer <tu-token-jwt>
```

## Ejemplo de Uso

### Registrar Usuario
```bash
curl -X POST http://localhost:3000/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "usuario_ejemplo",
    "email": "usuario@ejemplo.com",
    "password": "password123"
  }'
```

### Iniciar Sesión
```bash
curl -X POST http://localhost:3000/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "password123"
  }'
```

### Obtener Métricas Globales
```bash
curl http://localhost:3000/api/v1/metrics/global
```

## Almacenamiento de Datos

**Nota:** Esta implementación utiliza almacenamiento en memoria para demostración. En producción, deberías integrar una base de datos real (PostgreSQL, MongoDB, etc.).

## Seguridad

- ✅ Contraseñas hasheadas con bcrypt
- ✅ Tokens JWT con expiración
- ✅ Headers de seguridad con Helmet
- ✅ Validación de entrada con express-validator
- ✅ CORS configurable
- ✅ Manejo centralizado de errores

## Próximos Pasos

- [ ] Integrar base de datos (PostgreSQL/MongoDB)
- [ ] Implementar sistema de roles y permisos
- [ ] Añadir rate limiting
- [ ] Implementar caching con Redis
- [ ] Añadir documentación Swagger/OpenAPI interactiva
- [ ] Implementar tests unitarios e integración
- [ ] Añadir logging estructurado
- [ ] Implementar sistema de archivos para avatares

## Contribución

Este proyecto forma parte de la plataforma Audira. Para contribuir, contacta al equipo de desarrollo.

## Licencia

ISC
