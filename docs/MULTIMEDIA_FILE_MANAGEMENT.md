# Gestión de Archivos Multimedia - Audira

Esta documentación describe el sistema completo de gestión de archivos multimedia implementado en Audira, incluyendo upload, almacenamiento, streaming y compresión de archivos de audio e imagen.

## Índice

- [Características Implementadas](#características-implementadas)
- [Endpoints de API](#endpoints-de-api)
- [Configuración de Almacenamiento](#configuración-de-almacenamiento)
- [Formatos Soportados](#formatos-soportados)
- [Límites de Tamaño](#límites-de-tamaño)
- [Compresión y Optimización](#compresión-y-optimización)
- [Integración con Frontend](#integración-con-frontend)

## Características Implementadas

### ✅ GA01-51: Upload de Archivos de Audio
- Soporte para múltiples formatos: MP3, WAV, FLAC, MIDI, OGG, AAC
- Validación de formato y tamaño
- Límite de 50MB por archivo
- Almacenamiento en subdirectorio `audio-files/`

### ✅ GA01-52: Upload de Archivos de Imagen
- Formatos soportados: JPG, PNG, GIF, WEBP
- Validación por content-type y extensión
- Límites: 5MB (perfil), 10MB (banner/portada)
- Subdirectorios: `profile-images/`, `banner-images/`, `cover-images/`

### ✅ GA01-53: Almacenamiento Externo (S3)
- Integración completa con Amazon S3
- Compatible con servicios S3-compatible (MinIO, DigitalOcean Spaces, etc.)
- Alternancia automática entre almacenamiento local y S3
- Configuración via variables de entorno

### ✅ GA01-55: Streaming de Audio Eficiente
- Soporte para HTTP Range Requests
- Permite seek/scrubbing en archivos de audio
- Content-Type correcto según formato
- Headers optimizados para streaming

### ✅ GA01-56: Compresión de Archivos
- Compresión de imágenes con control de calidad
- Redimensionamiento manteniendo proporción
- Optimización automática de imágenes
- Estadísticas de compresión

## Endpoints de API

### Upload de Archivos

#### 1. Upload de Audio
```http
POST /api/files/upload/audio
Content-Type: multipart/form-data

Parameters:
  - file (required): Archivo de audio
  - songId (optional): ID de la canción asociada

Response:
{
  "message": "Archivo de audio subido exitosamente",
  "fileUrl": "http://example.com/api/files/audio-files/uuid.mp3",
  "filePath": "audio-files/uuid.mp3",
  "songId": 123
}
```

**Formatos aceptados:** .mp3, .wav, .flac, .midi, .mid, .ogg, .aac
**Tamaño máximo:** 50MB

#### 2. Upload de Imagen de Perfil
```http
POST /api/files/upload/profile-image
Content-Type: multipart/form-data

Parameters:
  - file (required): Archivo de imagen
  - userId (required): ID del usuario

Response:
{
  "message": "Imagen de perfil actualizada exitosamente",
  "fileUrl": "http://example.com/api/files/profile-images/uuid.jpg",
  "user": { ... }
}
```

**Formatos aceptados:** .jpg, .jpeg, .png, .gif, .webp
**Tamaño máximo:** 5MB

#### 3. Upload de Banner
```http
POST /api/files/upload/banner-image
Content-Type: multipart/form-data

Parameters:
  - file (required): Archivo de imagen
  - userId (required): ID del usuario

Response:
{
  "message": "Imagen de banner actualizada exitosamente",
  "fileUrl": "http://example.com/api/files/banner-images/uuid.jpg",
  "user": { ... }
}
```

**Formatos aceptados:** .jpg, .jpeg, .png, .gif, .webp
**Tamaño máximo:** 10MB

#### 4. Upload de Portada (Album/Song)
```http
POST /api/files/upload/cover-image
Content-Type: multipart/form-data

Parameters:
  - file (required): Archivo de imagen
  - productId (optional): ID del producto asociado

Response:
{
  "message": "Imagen de portada subida exitosamente",
  "fileUrl": "http://example.com/api/files/cover-images/uuid.jpg",
  "filePath": "cover-images/uuid.jpg",
  "productId": 456
}
```

**Formatos aceptados:** .jpg, .jpeg, .png, .gif, .webp
**Tamaño máximo:** 10MB

### Servir Archivos

#### 5. Servir Archivo (con Range Requests)
```http
GET /api/files/{subDirectory}/{fileName}
Headers:
  - Range: bytes=0-1023 (optional)

Response:
  - 200 OK: Archivo completo
  - 206 Partial Content: Rango del archivo
  - 404 Not Found: Archivo no encontrado
```

**Características:**
- Soporte automático para Range Requests en archivos de audio
- Content-Type correcto según extensión
- Header `Accept-Ranges: bytes` para indicar soporte de rangos
- Manejo de errores con rangos inválidos

### Compresión y Optimización

#### 6. Comprimir Imagen
```http
POST /api/files/compress/image
Content-Type: multipart/form-data

Parameters:
  - file (required): Archivo de imagen
  - quality (optional): Calidad 0.0-1.0 (default: 0.7)
  - maxWidth (optional): Ancho máximo en píxeles
  - maxHeight (optional): Alto máximo en píxeles

Response:
  Archivo de imagen comprimida (binary)

Headers:
  Content-Type: image/jpeg | image/png
  Content-Disposition: attachment; filename="compressed_original.jpg"
```

**Ejemplo de uso:**
```bash
curl -X POST http://localhost:9001/api/files/compress/image \
  -F "file=@image.jpg" \
  -F "quality=0.8" \
  -F "maxWidth=1920" \
  -F "maxHeight=1080" \
  --output compressed.jpg
```

#### 7. Optimizar Imagen
```http
POST /api/files/optimize/image
Content-Type: multipart/form-data

Parameters:
  - file (required): Archivo de imagen
  - subDirectory (required): Subdirectorio destino
  - quality (optional): Calidad 0.0-1.0 (default: 0.8)
  - maxWidth (optional): Ancho máximo (default: 1920)
  - maxHeight (optional): Alto máximo (default: 1080)

Response:
{
  "message": "Imagen optimizada exitosamente",
  "originalSize": 5242880,
  "optimizedSize": 1048576,
  "compressionRatio": "80.00%"
}
```

## Configuración de Almacenamiento

### Almacenamiento Local (Por Defecto)

Configurado en `application.yml`:

```yaml
file:
  upload-dir: uploads
  base-url: http://158.49.191.109:9001

spring.servlet.multipart:
  enabled: true
  max-file-size: 50MB
  max-request-size: 50MB
```

**Estructura de directorios:**
```
uploads/
├── profile-images/
├── banner-images/
├── cover-images/
└── audio-files/
```

### Almacenamiento en S3

#### Configuración Básica (AWS S3)

```yaml
aws:
  s3:
    enabled: true
    access-key: YOUR_AWS_ACCESS_KEY
    secret-key: YOUR_AWS_SECRET_KEY
    bucket-name: audira-media
    region: us-east-1
```

#### Configuración con Variables de Entorno

```bash
export AWS_ACCESS_KEY=your_access_key
export AWS_SECRET_KEY=your_secret_key
export AWS_S3_BUCKET=audira-media
export AWS_REGION=us-east-1
```

#### Servicios Compatibles con S3

##### MinIO (S3 Local)
```yaml
aws:
  s3:
    enabled: true
    access-key: minioadmin
    secret-key: minioadmin
    bucket-name: audira-media
    region: us-east-1
    endpoint: http://localhost:9000
```

##### DigitalOcean Spaces
```yaml
aws:
  s3:
    enabled: true
    access-key: YOUR_DO_SPACES_KEY
    secret-key: YOUR_DO_SPACES_SECRET
    bucket-name: audira-media
    region: nyc3
    endpoint: https://nyc3.digitaloceanspaces.com
    public-url: https://audira-media.nyc3.cdn.digitaloceanspaces.com
```

##### Cloudflare R2
```yaml
aws:
  s3:
    enabled: true
    access-key: YOUR_R2_ACCESS_KEY
    secret-key: YOUR_R2_SECRET_KEY
    bucket-name: audira-media
    region: auto
    endpoint: https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com
```

## Formatos Soportados

### Archivos de Audio

| Formato | Extensión | MIME Type | Notas |
|---------|-----------|-----------|-------|
| MP3 | .mp3 | audio/mpeg | Más común, buena compresión |
| WAV | .wav | audio/wav | Sin compresión, alta calidad |
| FLAC | .flac | audio/flac | Lossless, comprimido |
| MIDI | .midi, .mid | audio/midi | Secuencias musicales |
| OGG | .ogg | audio/ogg | Alternativa libre a MP3 |
| AAC | .aac | audio/aac | Mejor compresión que MP3 |

### Archivos de Imagen

| Formato | Extensión | MIME Type | Notas |
|---------|-----------|-----------|-------|
| JPEG | .jpg, .jpeg | image/jpeg | Fotografías, buena compresión |
| PNG | .png | image/png | Transparencia, sin pérdida |
| GIF | .gif | image/gif | Animaciones, paleta limitada |
| WebP | .webp | image/webp | Moderno, mejor compresión |

## Límites de Tamaño

| Tipo de Archivo | Límite | Configuración |
|-----------------|--------|---------------|
| Imagen de Perfil | 5 MB | Hardcoded en controller |
| Imagen de Banner | 10 MB | Hardcoded en controller |
| Imagen de Portada | 10 MB | Hardcoded en controller |
| Archivo de Audio | 50 MB | Hardcoded en controller |
| Límite Global | 50 MB | `spring.servlet.multipart.max-file-size` |

## Compresión y Optimización

### Algoritmos de Compresión de Imágenes

**Librería utilizada:** imgscalr (org.imgscalr:imgscalr-lib:4.2)

#### Métodos Disponibles

1. **Compresión con Calidad**
   - Parámetro: `quality` (0.0 - 1.0)
   - 0.0 = máxima compresión, mínima calidad
   - 1.0 = mínima compresión, máxima calidad
   - Recomendado: 0.7 - 0.85

2. **Redimensionamiento**
   - Mantiene proporción automáticamente
   - Parámetros: `maxWidth`, `maxHeight`
   - Algoritmo: Scalr.Method.QUALITY

3. **Compresión + Redimensionamiento**
   - Combina ambas técnicas
   - Optimización óptima de tamaño

#### Ejemplos de Uso

**Solo Compresión:**
```bash
curl -X POST http://localhost:9001/api/files/compress/image \
  -F "file=@photo.jpg" \
  -F "quality=0.8" \
  --output optimized.jpg
```

**Compresión + Redimensionamiento:**
```bash
curl -X POST http://localhost:9001/api/files/compress/image \
  -F "file=@photo.jpg" \
  -F "quality=0.8" \
  -F "maxWidth=1920" \
  -F "maxHeight=1080" \
  --output optimized.jpg
```

**Obtener Estadísticas:**
```bash
curl -X POST http://localhost:9001/api/files/optimize/image \
  -F "file=@photo.jpg" \
  -F "subDirectory=optimized" \
  -F "quality=0.8"
```

### Compresión de Audio

**Nota:** La compresión de audio (transcoding) requiere herramientas externas como FFmpeg, que no están incluidas en esta implementación Java.

Para implementar compresión de audio, se recomienda:

1. **Usar un servicio externo:**
   - AWS Elastic Transcoder
   - Cloudinary (soporta audio)
   - FFmpeg como servicio separado

2. **Implementar con FFmpeg:**
   ```java
   // Ejemplo conceptual (requiere FFmpeg instalado)
   ProcessBuilder pb = new ProcessBuilder(
       "ffmpeg",
       "-i", inputFile,
       "-b:a", "128k",  // Bitrate
       "-ar", "44100",  // Sample rate
       outputFile
   );
   ```

3. **Formatos de compresión recomendados:**
   - MP3: 128-320 kbps
   - AAC: 96-256 kbps (mejor calidad/tamaño que MP3)
   - OGG Vorbis: 128-192 kbps

## Integración con Frontend

### Ejemplo Flutter: Upload de Audio

```dart
Future<String?> uploadAudioFile(File audioFile, {int? songId}) async {
  final uri = Uri.parse('$baseUrl/api/files/upload/audio');

  var request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    audioFile.path,
    contentType: MediaType('audio', 'mpeg'),
  ));

  if (songId != null) {
    request.fields['songId'] = songId.toString();
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    var json = jsonDecode(responseData);
    return json['fileUrl'];
  }

  return null;
}
```

### Ejemplo Flutter: Upload de Imagen con Compresión

```dart
Future<String?> uploadAndCompressImage(File imageFile, String userId) async {
  // 1. Primero comprimir localmente con flutter_image_compress
  final compressedBytes = await FlutterImageCompress.compressWithFile(
    imageFile.absolute.path,
    quality: 85,
    minWidth: 1920,
    minHeight: 1080,
  );

  // 2. Subir imagen comprimida
  final uri = Uri.parse('$baseUrl/api/files/upload/profile-image');

  var request = http.MultipartRequest('POST', uri);
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    compressedBytes!,
    filename: 'profile.jpg',
    contentType: MediaType('image', 'jpeg'),
  ));
  request.fields['userId'] = userId;

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    var json = jsonDecode(responseData);
    return json['fileUrl'];
  }

  return null;
}
```

### Ejemplo Flutter: Streaming de Audio con just_audio

```dart
import 'package:just_audio/just_audio.dart';

final player = AudioPlayer();

// Cargar y reproducir
await player.setUrl('$baseUrl/api/files/audio-files/uuid.mp3');
await player.play();

// El soporte de Range Requests permite:
// - Seek instantáneo
// - Buffering eficiente
// - Reproducción desde cualquier punto
await player.seek(Duration(seconds: 30));
```

## Seguridad

### Validaciones Implementadas

1. **Validación de Formato:**
   - Por Content-Type
   - Por extensión de archivo
   - Doble verificación para mayor seguridad

2. **Validación de Tamaño:**
   - Límites por tipo de archivo
   - Límite global de Spring Boot

3. **Sanitización de Nombres:**
   - Limpieza de caracteres especiales
   - Prevención de path traversal (..)
   - Nombres únicos con UUID

4. **Almacenamiento Seguro:**
   - Directorios separados por tipo
   - Permisos de lectura pública solo cuando es necesario
   - URLs firmadas para S3 (opcional)

### Recomendaciones Adicionales

1. **Autenticación:**
   - Requerir JWT token para uploads
   - Validar permisos de usuario

2. **Rate Limiting:**
   - Limitar uploads por usuario/IP
   - Prevenir abuso de recursos

3. **Escaneo de Malware:**
   - Integrar ClamAV o similar
   - Escanear archivos antes de almacenar

4. **Content Security:**
   - Validar contenido real del archivo (magic numbers)
   - No confiar solo en extensiones

## Monitoreo y Métricas

### Endpoints de Actuator

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
```

**Métricas recomendadas para monitorear:**
- Tamaño total de archivos almacenados
- Número de uploads por tipo
- Tasa de fallos en uploads
- Uso de ancho de banda
- Tasa de compresión promedio

## Troubleshooting

### Error: "No se pudo almacenar el archivo"
- Verificar permisos del directorio `uploads/`
- Verificar espacio en disco
- Revisar logs para más detalles

### Error: "El archivo no debe superar los XMB"
- Verificar tamaño del archivo
- Ajustar límites en application.yml si es necesario

### Error: "S3 no está habilitado o configurado correctamente"
- Verificar credenciales AWS
- Verificar que `aws.s3.enabled=true`
- Verificar conectividad con S3

### Streaming no funciona (no se puede hacer seek)
- Verificar que el servidor soporte Range Requests
- Verificar headers en la respuesta
- Probar con diferentes reproductores

## Próximos Pasos

### Mejoras Futuras

1. **Procesamiento Asíncrono:**
   - Upload de archivos grandes en background
   - Notificaciones de progreso

2. **Thumbnails Automáticos:**
   - Generar previsualizaciones de imágenes
   - Múltiples tamaños para responsive

3. **Metadatos de Audio:**
   - Extraer ID3 tags
   - Obtener duración automáticamente
   - Extraer artwork

4. **CDN Integration:**
   - CloudFront (AWS)
   - Cloudflare
   - Cache optimizado

5. **Compresión de Audio:**
   - Integración con FFmpeg
   - Transcoding automático
   - Múltiples calidades (128k, 256k, 320k)

## Referencias

- [Spring Boot File Upload](https://spring.io/guides/gs/uploading-files/)
- [AWS S3 Java SDK](https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/examples-s3.html)
- [HTTP Range Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests)
- [imgscalr Documentation](https://github.com/rkalla/imgscalr)
- [just_audio Flutter Package](https://pub.dev/packages/just_audio)

## Soporte

Para reportar problemas o sugerir mejoras, por favor crea un issue en el repositorio del proyecto.

---

**Última actualización:** 2025-11-05
**Versión:** 1.0.0
**Autor:** Audira Development Team
