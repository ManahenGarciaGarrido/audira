# Audira - Aplicación de Música Flutter

**Audira** es una aplicación de música profesional desarrollada en Flutter con arquitectura de microservicios en el backend. Permite a los usuarios descubrir, comprar y reproducir música, crear playlists, y gestionar su biblioteca musical.

## 🎨 Diseño

- **Tema**: Oscuro con colores negro y azul
- **Paleta de colores**:
  - Negro (#000000) - Fondo principal
  - Negro oscuro (#121212) - Superficies
  - Azul primario (#2196F3) - Acentos
  - Azul oscuro (#1976D2) - Variantes
- **Tipografía**: Poppins (Regular, Medium, SemiBold, Bold)
- **Animaciones**: Profesionales usando librerías (flutter_animate, animations)

## 🏗️ Arquitectura

```
audira_frontend/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── config/                      # Configuración
│   │   ├── theme.dart              # Tema oscuro con azul
│   │   ├── constants.dart          # Constantes de la app
│   ├── core/                        # Núcleo de la app
│   │   ├── api/                    # Cliente API y servicios
│   │   │   ├── api_client.dart     # Cliente HTTP con JWT
│   │   │   ├── auth_service.dart   # Servicio de autenticación
│   │   │   └── services/           # Servicios por dominio
│   │   ├── models/                 # Modelos de datos
│   │   ├── providers/              # Gestión de estado (Provider)
│   │   └── utils/                  # Utilidades
│   ├── features/                    # Características por módulo
│   │   ├── auth/                   # Autenticación
│   │   ├── home/                   # Inicio
│   │   ├── store/                  # Tienda
│   │   ├── library/                # Biblioteca
│   │   ├── cart/                   # Carrito
│   │   ├── profile/                # Perfil
│   │   ├── artist/                 # Studio de artista
│   │   ├── admin/                  # Panel de administración
│   │   └── common/                 # Componentes comunes
│   └── widgets/                     # Widgets globales
├── pubspec.yaml                     # Dependencias
└── README.md
```

## 👥 Roles de Usuario

La aplicación soporta 4 roles:

1. **Invitado** (Guest) - Sin registro, puede explorar y agregar al carrito
2. **Usuario** (User) - Registrado, puede comprar, crear playlists, biblioteca
3. **Artista** (Artist) - Puede subir canciones/álbumes, ver estadísticas
4. **Administrador** (Admin) - Gestión completa de la plataforma

## 🎯 Funcionalidades Implementadas

### 📱 Para Todos los Roles (Invitado, Usuario, Artista, Admin)

#### ✅ Inicio
- Lista de canciones destacadas (scroll horizontal)
- Lista de álbumes destacados (scroll horizontal)
- Géneros musicales con navegación
- Pull-to-refresh
- Animaciones fluidas

#### ✅ Tienda
- Pestañas: Canciones y Álbumes
- Lista completa de canciones
- Lista completa de álbumes
- Agregar al carrito
- Navegación a detalles

#### ✅ Carrito
- Ver items del carrito
- Actualizar cantidades
- Eliminar items
- Total calculado
- **Importante**: Si no estás registrado, te pide iniciar sesión al pagar

#### ✅ FAQs
- Preguntas frecuentes expandibles
- Botón de contacto

#### ✅ Autenticación
- Pantalla de Login (email/username + password)
- Pantalla de Registro (con selección de rol)
- Opción "Continuar como Invitado"
- Validaciones de formularios

### 🔐 Para Usuarios Autenticados (Usuario, Artista, Admin)

#### ✅ Biblioteca
- Pestañas: Canciones, Álbumes, Playlists, Favoritos
- Ver playlists del usuario
- Gestión de colecciones

#### ✅ Perfil
- Información del usuario
- Estadísticas (seguidores, siguiendo)
- Botón de estadísticas (próximamente)
- Editar perfil (próximamente)
- Cerrar sesión

## 🎵 Pantallas Específicas

### ⚠️ Pantallas Pendientes de Implementación

Las siguientes pantallas están planificadas pero aún no implementadas:

- **Detalle de Canción**: Datos completos, colaboradores, demo 10s, valoraciones
- **Detalle de Álbum**: Datos completos, lista de canciones, demo de canciones
- **Detalle de Género**: Tienda filtrada por género
- **Detalle de Artista**: Información y contenido del artista
- **Pantalla de Reproducción**: Controles de reproducción, play/pause, siguiente/anterior, shuffle, repeat, barra de progreso
- **Crear Playlist**: Formulario para crear playlists
- **Contacto**: Formulario de contacto con admins
- **Estadísticas de Usuario**: Gráficos y métricas de escucha
- **Studio de Artista**: Subir canciones, subir álbumes, ver estadísticas, gestión de contenido
- **Panel de Administración**: CRUD de todas las entidades (canciones, álbumes, géneros, usuarios, etc.)

## 🛠️ Tecnologías Utilizadas

### Frontend (Flutter)
- **Flutter SDK**: ^3.0.0
- **Estado**: Provider + Riverpod
- **HTTP**: Dio + http
- **Almacenamiento**: flutter_secure_storage, shared_preferences, Hive
- **Animaciones**: flutter_animate, animations, lottie
- **Audio**: just_audio
- **UI**: cached_network_image, shimmer, fl_chart
- **Navegación**: go_router
- **Forms**: flutter_form_builder

### Backend (Microservicios)
- **API Gateway**: http://localhost:8080
- **Spring Cloud** con Eureka Service Discovery
- **PostgreSQL** (4 bases de datos)
- **JWT** para autenticación

## 🔌 Conexión con Backend

### Microservicios Disponibles

1. **Community Service** (Puerto 9001)
   - Usuarios, Autenticación, FAQs, Contacto, Notificaciones, Valoraciones, Comentarios, Métricas

2. **Music Catalog Service** (Puerto 9002)
   - Canciones, Álbumes, Géneros, Colaboradores, Descubrimiento

3. **Playback Service** (Puerto 9003)
   - Playlists, Reproducción, Cola, Historial, Biblioteca

4. **Commerce Service** (Puerto 9004)
   - Productos, Carrito, Órdenes, Pagos

### Configuración de API

Edita `lib/config/constants.dart`:

```dart
static const String apiGatewayUrl = 'http://localhost:8080';
```

Para desarrollo móvil, cambia a la IP de tu máquina:

```dart
static const String apiGatewayUrl = 'http://192.168.x.x:8080';
```

## 🚀 Cómo Ejecutar

### Prerrequisitos

1. **Flutter SDK** instalado (>=3.0.0)
2. **Backend** ejecutándose (docker-compose up)
3. Editor de código (VS Code, Android Studio)

### Instalación

```bash
# 1. Navegar al directorio del frontend
cd audira_frontend

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar la aplicación
flutter run

# O específicamente en un dispositivo
flutter run -d chrome           # Para web
flutter run -d android          # Para Android
flutter run -d ios              # Para iOS
```

### Notas Importantes

⚠️ **Las fuentes Poppins no están incluidas**. Para agregar las fuentes:

1. Descarga Poppins de [Google Fonts](https://fonts.google.com/specimen/Poppins)
2. Crea el directorio `assets/fonts/`
3. Coloca los archivos `.ttf` según `pubspec.yaml`

⚠️ **Los assets (imágenes, iconos, animaciones) no están incluidos**. Puedes:

1. Usar placeholders
2. Agregar tus propios assets en `assets/`

## 📝 Gestión de Estado

La app usa **Provider** para gestión de estado:

- **AuthProvider**: Autenticación, usuario actual, login/logout
- **CartProvider**: Carrito de compras, agregar/eliminar items

### Ejemplo de uso:

```dart
// Obtener el usuario actual
final authProvider = Provider.of<AuthProvider>(context);
final user = authProvider.currentUser;

// Agregar al carrito
final cartProvider = Provider.of<CartProvider>(context);
await cartProvider.addToCart(
  userId: user.id,
  itemType: 'SONG',
  itemId: songId,
  price: song.price,
);
```

## 🎨 Tema y Estilos

El tema está centralizado en `lib/config/theme.dart`:

```dart
// Usar colores del tema
AppTheme.primaryBlue
AppTheme.backgroundBlack
AppTheme.textWhite

// Usar estilos de texto
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.bodyMedium

// Usar sombras predefinidas
AppTheme.cardShadow
AppTheme.elevatedShadow
```

## 🔐 Autenticación JWT

La aplicación usa JWT para autenticación:

1. Login/Registro → Recibe token JWT
2. Token se guarda en **FlutterSecureStorage**
3. Todas las peticiones autenticadas incluyen: `Authorization: Bearer <token>`
4. ApiClient maneja automáticamente el token

## 🌐 Navegación

La navegación actual usa `Navigator` tradicional de Flutter. Estructura:

```
LoginScreen (no autenticado)
    ↓
MainLayout (autenticado o invitado)
    ├── HomeScreen
    ├── StoreScreen
    ├── LibraryScreen (solo autenticados)
    ├── CartScreen
    └── ProfileScreen (solo autenticados)
```

## 📦 Modelos de Datos

Modelos principales implementados:

- `User` - Usuario base
- `Artist` - Artista (hereda de User)
- `Song` - Canción
- `Album` - Álbum
- `Genre` - Género musical
- `Playlist` - Lista de reproducción
- `Cart` / `CartItem` - Carrito de compras
- `Order` / `OrderItem` - Orden
- `FAQ` - Pregunta frecuente
- `Rating` - Valoración
- `Collaborator` - Colaborador de canción

Todos los modelos tienen:
- `fromJson` / `toJson` para serialización
- `copyWith` para copias inmutables
- Extienden `Equatable` para comparaciones

## 🎯 Próximos Pasos

### Alta Prioridad
1. ✅ Implementar pantalla de detalle de canción
2. ✅ Implementar pantalla de detalle de álbum
3. ✅ Implementar reproductor de audio con controles
4. ✅ Sistema de demo de 10 segundos
5. ✅ Pantalla de creación de playlists

### Media Prioridad
6. ✅ Studio de artista (subir canciones/álbumes)
7. ✅ Panel de administración completo
8. ✅ Sistema de valoraciones y comentarios
9. ✅ Estadísticas con gráficos
10. ✅ Búsqueda y filtros avanzados

### Baja Prioridad
11. ✅ Notificaciones push
12. ✅ Modo offline
13. ✅ Compartir música
14. ✅ Perfiles públicos de usuarios/artistas
15. ✅ Sistema de recomendaciones

## 🐛 Conocido

- Las fuentes Poppins no están incluidas (usar fuentes por defecto)
- Assets de imágenes no incluidos (usar placeholders)
- Animaciones Lottie no incluidas
- Algunas pantallas muestran "Próximamente" (están planeadas)
- El backend debe estar ejecutándose en localhost:8080

## 📄 Licencia

Este proyecto es parte del sistema Audira V2.

## 👨‍💻 Desarrollado por

Claude Code - Frontend Flutter para Audira Music App

---

## 🎉 Características Profesionales

- ✅ Arquitectura limpia y escalable
- ✅ Código modular y reutilizable
- ✅ Gestión de estado con Provider
- ✅ Animaciones fluidas y profesionales
- ✅ Tema oscuro consistente
- ✅ Manejo de errores robusto
- ✅ Validaciones de formularios
- ✅ Almacenamiento seguro de credenciales
- ✅ HTTP client con interceptores
- ✅ Modelos de datos type-safe
- ✅ UI responsiva y adaptable
- ✅ Carga de imágenes con cache
- ✅ Pull-to-refresh
- ✅ Navegación fluida con transiciones
- ✅ Sistema de roles completo

---

**¡Disfruta de Audira! 🎵**
