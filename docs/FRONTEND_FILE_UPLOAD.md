# Guía de Uso: Sistema de Upload de Archivos Multimedia - Frontend Flutter

Esta guía explica cómo usar el sistema de upload de archivos multimedia implementado en el frontend de Audira.

## Tabla de Contenidos

1. [Archivos Creados](#archivos-creados)
2. [Dependencias](#dependencias)
3. [Configuración](#configuración)
4. [Uso de Widgets](#uso-de-widgets)
5. [Servicio de Upload](#servicio-de-upload)
6. [Ejemplos de Implementación](#ejemplos-de-implementación)

---

## Archivos Creados

### 1. **ApiClient** - Modificado
**Ubicación:** `lib/core/api/api_client.dart`

**Cambios:**
- Agregado método `postMultipart()` para uploads de archivos (líneas 232-293)
- Agregado método `_getMimeType()` para detectar tipos MIME (líneas 295-314)
- Importado `dart:io` y `http_parser` para manejo de archivos

**Método clave:**
```dart
Future<ApiResponse<T>> postMultipart<T>(
  String endpoint, {
  required File file,
  required String fileFieldName,
  Map<String, String>? fields,
  Map<String, String>? queryParameters,
  bool requiresAuth = true,
  String? contentType,
})
```

### 2. **FileUploadResponse Model** - Nuevo
**Ubicación:** `lib/core/models/file_upload_response.dart`

**Modelos:**
- `FileUploadResponse`: Respuesta del servidor al subir archivos
- `ImageCompressionStats`: Estadísticas de compresión de imágenes

**Campos principales:**
```dart
class FileUploadResponse {
  final String? fileUrl;       // URL completa del archivo
  final String? filePath;      // Ruta relativa del archivo
  final int? songId;          // ID de canción asociada (opcional)
  final int? productId;       // ID de producto asociado (opcional)
  final String? message;      // Mensaje del servidor
}
```

### 3. **FileUploadService** - Nuevo
**Ubicación:** `lib/core/api/services/file_upload_service.dart`

**Métodos disponibles:**

#### Upload de Audio
```dart
Future<ApiResponse<FileUploadResponse>> uploadAudioFile(
  File audioFile, {
  int? songId,
})
```
- Formatos soportados: MP3, WAV, FLAC, MIDI, OGG, AAC
- Tamaño máximo: 50MB

#### Upload de Imágenes
```dart
// Imagen de perfil (máx 5MB)
Future<ApiResponse<FileUploadResponse>> uploadProfileImage(
  File imageFile, {
  int? userId,
})

// Imagen de banner (máx 10MB)
Future<ApiResponse<FileUploadResponse>> uploadBannerImage(
  File imageFile, {
  int? userId,
})

// Imagen de portada (máx 10MB)
Future<ApiResponse<FileUploadResponse>> uploadCoverImage(
  File imageFile, {
  int? productId,
})
```
- Formatos soportados: JPG, PNG, GIF, WEBP

#### Compresión de Imágenes
```dart
// Obtener estadísticas de compresión
Future<ApiResponse<ImageCompressionStats>> getImageCompressionStats(
  File imageFile, {
  double quality = 0.8,
  int? maxWidth,
  int? maxHeight,
})
```

#### Utilidades
```dart
String getFileUrl(String filePath)  // Construir URL completa
bool isValidAudioFile(File file)    // Validar formato de audio
bool isValidImageFile(File file)    // Validar formato de imagen
int get maxAudioFileSize            // 50MB en bytes
int get maxProfileImageSize         // 5MB en bytes
int get maxBannerImageSize          // 10MB en bytes
```

### 4. **AudioFilePicker Widget** - Nuevo
**Ubicación:** `lib/features/common/widgets/audio_file_picker.dart`

Widget completo para seleccionar y subir archivos de audio.

**Propiedades:**
```dart
AudioFilePicker({
  required Function(FileUploadResponse) onUploadComplete,
  Function(String)? onUploadError,
  int? songId,
  String buttonText = 'Seleccionar Audio',
  bool showProgress = true,
})
```

**Características:**
- Selector de archivos con filtro de extensiones
- Validación automática de formato y tamaño
- Indicador de progreso durante la subida
- Manejo de errores con SnackBars
- Muestra nombre del archivo seleccionado

### 5. **ImageFilePicker Widget** - Nuevo
**Ubicación:** `lib/features/common/widgets/image_file_picker.dart`

Widget completo para seleccionar y subir imágenes.

**Tipos de upload:**
```dart
enum ImageUploadType {
  profile,   // Foto de perfil
  banner,    // Banner
  cover,     // Portada
}
```

**Propiedades:**
```dart
ImageFilePicker({
  required ImageUploadType uploadType,
  required Function(FileUploadResponse) onUploadComplete,
  Function(String)? onUploadError,
  int? userId,
  int? productId,
  String? buttonText,
  bool showPreview = true,
  double? previewHeight,
})
```

**Características:**
- Selección desde cámara o galería
- Preview de la imagen seleccionada
- Optimización automática según tipo
- Validación de formato y tamaño
- Manejo de errores con SnackBars
- UI adaptable según tipo de imagen

### 6. **Constants** - Modificado
**Ubicación:** `lib/config/constants.dart`

**Nuevas constantes agregadas:**
```dart
// File endpoints
static const String fileUploadUrl = '/api/files/upload';
static const String fileUploadAudioUrl = '/api/files/upload/audio';
static const String fileUploadProfileImageUrl = '/api/files/upload/profile-image';
static const String fileUploadBannerImageUrl = '/api/files/upload/banner-image';
static const String fileUploadCoverImageUrl = '/api/files/upload/cover-image';
static const String fileCompressImageUrl = '/api/files/compress/image';
static const String fileOptimizeImageUrl = '/api/files/optimize/image';
static const String fileServeUrl = '/api/files';
```

---

## Dependencias

El proyecto ya incluye todas las dependencias necesarias en `pubspec.yaml`:

```yaml
dependencies:
  # File Picker
  file_picker: ^8.1.6         # Para seleccionar archivos de audio

  # Image Picker
  image_picker: ^1.0.7        # Para seleccionar imágenes

  # HTTP
  http: ^1.2.0               # Para peticiones HTTP
  http_parser: ^4.0.2        # Para multipart/form-data

  # Audio Player
  just_audio: ^0.10.5        # Ya soporta streaming HTTP
```

**No se requieren dependencias adicionales.**

---

## Configuración

### Backend URL

Verificar que la URL del backend esté configurada correctamente en `lib/config/constants.dart`:

```dart
static const String apiGatewayUrl = 'http://158.49.191.109:8080';
```

Para desarrollo local, cambiar a:
```dart
static const String apiGatewayUrl = 'http://localhost:9001';
```

---

## Uso de Widgets

### 1. Upload de Audio

```dart
import 'package:audira_frontend/features/common/widgets/audio_file_picker.dart';

class MyAudioUploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subir Audio')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: AudioFilePicker(
          songId: 123, // Opcional
          buttonText: 'Seleccionar Archivo de Audio',
          showProgress: true,
          onUploadComplete: (response) {
            print('Audio subido: ${response.fileUrl}');
            // Actualizar la UI o navegar a otra pantalla
          },
          onUploadError: (error) {
            print('Error: $error');
            // Manejar el error
          },
        ),
      ),
    );
  }
}
```

### 2. Upload de Imagen de Perfil

```dart
import 'package:audira_frontend/features/common/widgets/image_file_picker.dart';

class ProfileImageUploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Foto de Perfil')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ImageFilePicker(
          uploadType: ImageUploadType.profile,
          userId: 456, // Opcional
          showPreview: true,
          previewHeight: 200,
          onUploadComplete: (response) {
            print('Imagen subida: ${response.fileUrl}');
            // Actualizar el perfil del usuario
          },
          onUploadError: (error) {
            print('Error: $error');
          },
        ),
      ),
    );
  }
}
```

### 3. Upload de Banner

```dart
ImageFilePicker(
  uploadType: ImageUploadType.banner,
  userId: currentUserId,
  buttonText: 'Cambiar Banner',
  showPreview: true,
  onUploadComplete: (response) {
    // Banner actualizado
    setState(() {
      bannerUrl = response.fileUrl;
    });
  },
)
```

### 4. Upload de Portada de Álbum/Canción

```dart
ImageFilePicker(
  uploadType: ImageUploadType.cover,
  productId: albumId,
  buttonText: 'Seleccionar Portada',
  showPreview: true,
  previewHeight: 300,
  onUploadComplete: (response) {
    // Portada actualizada
    setState(() {
      coverImageUrl = response.fileUrl;
    });
  },
)
```

---

## Servicio de Upload

### Uso Directo del Servicio (sin widgets)

Si necesitas más control, puedes usar el servicio directamente:

```dart
import 'package:audira_frontend/core/api/services/file_upload_service.dart';
import 'dart:io';

class MyCustomUploadLogic {
  final FileUploadService _fileUploadService = FileUploadService();

  Future<void> uploadMyAudio(File audioFile) async {
    // Validar archivo
    if (!_fileUploadService.isValidAudioFile(audioFile)) {
      print('Formato inválido');
      return;
    }

    // Verificar tamaño
    final size = await audioFile.length();
    if (size > _fileUploadService.maxAudioFileSize) {
      print('Archivo muy grande');
      return;
    }

    // Subir
    final response = await _fileUploadService.uploadAudioFile(
      audioFile,
      songId: 123,
    );

    if (response.success && response.data != null) {
      print('URL: ${response.data!.fileUrl}');
      print('Path: ${response.data!.filePath}');
    } else {
      print('Error: ${response.error}');
    }
  }
}
```

---

## Ejemplos de Implementación

### Ejemplo 1: Formulario de Creación de Canción

```dart
class CreateSongScreen extends StatefulWidget {
  @override
  _CreateSongScreenState createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  String? audioFileUrl;
  String? coverImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Canción')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Campo de nombre
          TextField(
            decoration: InputDecoration(labelText: 'Nombre de la canción'),
          ),

          SizedBox(height: 24),

          // Upload de portada
          Text('Portada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ImageFilePicker(
            uploadType: ImageUploadType.cover,
            showPreview: true,
            onUploadComplete: (response) {
              setState(() {
                coverImageUrl = response.fileUrl;
              });
            },
          ),

          SizedBox(height: 24),

          // Upload de audio
          Text('Archivo de Audio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          AudioFilePicker(
            onUploadComplete: (response) {
              setState(() {
                audioFileUrl = response.fileUrl;
              });
            },
          ),

          SizedBox(height: 24),

          // Botón de guardar
          ElevatedButton(
            onPressed: audioFileUrl != null ? _saveSong : null,
            child: Text('Guardar Canción'),
          ),
        ],
      ),
    );
  }

  void _saveSong() {
    // Guardar la canción con audioFileUrl y coverImageUrl
    print('Audio: $audioFileUrl');
    print('Cover: $coverImageUrl');
  }
}
```

### Ejemplo 2: Actualizar Perfil de Usuario

```dart
class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? newProfileImageUrl;
  String? newBannerImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Banner
          Text('Banner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ImageFilePicker(
            uploadType: ImageUploadType.banner,
            userId: widget.user.id,
            showPreview: true,
            previewHeight: 150,
            onUploadComplete: (response) {
              setState(() {
                newBannerImageUrl = response.fileUrl;
              });
            },
          ),

          SizedBox(height: 24),

          // Foto de perfil
          Text('Foto de Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ImageFilePicker(
            uploadType: ImageUploadType.profile,
            userId: widget.user.id,
            showPreview: true,
            previewHeight: 200,
            onUploadComplete: (response) {
              setState(() {
                newProfileImageUrl = response.fileUrl;
              });
            },
          ),

          SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saveProfile,
            child: Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    // Actualizar el perfil del usuario
    print('New profile image: $newProfileImageUrl');
    print('New banner image: $newBannerImageUrl');
  }
}
```

### Ejemplo 3: Reproducir Audio con Streaming

El sistema ya soporta streaming automáticamente. El `AudioProvider` existente usa `just_audio`, que maneja Range Requests automáticamente:

```dart
// El AudioProvider ya existente maneja el streaming
class PlaySongExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return ElevatedButton(
      onPressed: () {
        // El audioUrl debe apuntar al endpoint del backend
        // Ejemplo: http://158.49.191.109:8080/api/files/audio-files/uuid-archivo.mp3
        final song = Song(
          id: 1,
          name: 'Mi Canción',
          audioUrl: 'http://158.49.191.109:8080/api/files/audio-files/12345.mp3',
        );

        // just_audio automáticamente usa Range Requests para streaming
        audioProvider.playSong(song);
      },
      child: Text('Reproducir'),
    );
  }
}
```

---

## Validaciones y Límites

### Audio
- **Formatos:** MP3, WAV, FLAC, MIDI, OGG, AAC
- **Tamaño máximo:** 50MB
- **Validación:** Por extensión y content-type

### Imágenes

#### Perfil
- **Formatos:** JPG, PNG, GIF, WEBP
- **Tamaño máximo:** 5MB
- **Resolución recomendada:** 1024x1024

#### Banner/Cover
- **Formatos:** JPG, PNG, GIF, WEBP
- **Tamaño máximo:** 10MB
- **Resolución recomendada:** 2048x1024 (banner), 1024x1024 (cover)

---

## Manejo de Errores

Todos los widgets manejan errores automáticamente mostrando SnackBars. También puedes capturar errores con el callback `onUploadError`:

```dart
AudioFilePicker(
  onUploadComplete: (response) {
    // Éxito
  },
  onUploadError: (error) {
    // Errores comunes:
    // - "Formato de audio no válido"
    // - "El archivo excede el tamaño máximo de 50MB"
    // - "Error de conexión. Verifica tu internet."
    // - "No autorizado. Inicia sesión nuevamente."

    // Mostrar diálogo personalizado
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error al subir archivo'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  },
)
```

---

## Notas Técnicas

### Streaming de Audio

El backend implementa HTTP Range Requests (RFC 7233) para permitir:
- Seek/scrub en archivos de audio sin descargar todo el archivo
- Reproducción progresiva
- Menor uso de ancho de banda

El `just_audio` player ya soporta esto automáticamente cuando se usa `setUrl()` con una URL HTTP.

### Compresión de Imágenes

El widget `ImageFilePicker` comprime automáticamente las imágenes antes de subirlas:
- **Perfil:** máx 1024x1024, calidad 85%
- **Banner/Cover:** máx 2048x2048, calidad 85%

Esto reduce el tiempo de subida y el uso de almacenamiento.

### Autenticación

Todos los endpoints de upload requieren autenticación. El `ApiClient` automáticamente incluye el token JWT en las peticiones cuando `requiresAuth: true`.

---

## Troubleshooting

### Error: "No autorizado"
- Verificar que el usuario esté logueado
- Verificar que el token JWT sea válido
- Reiniciar sesión si es necesario

### Error: "Formato no válido"
- Verificar que el archivo tenga la extensión correcta
- Verificar que no esté corrupto
- Intentar con otro archivo

### Error: "Archivo muy grande"
- Comprimir el archivo antes de subirlo
- Para imágenes: reducir resolución
- Para audio: reducir calidad/bitrate

### Imagen no se muestra después de subir
- Verificar que `fileUrl` esté correctamente formada
- Verificar conectividad con el backend
- Revisar logs del servidor

---

## Próximos Pasos

1. **Integrar con formularios reales** de creación de canciones/álbumes
2. **Agregar indicadores de progreso** más detallados
3. **Implementar compresión de audio** en el backend si es necesario
4. **Agregar cache de archivos** para reproducción offline
5. **Implementar retry logic** para uploads fallidos

---

**Última actualización:** 2025-11-05
