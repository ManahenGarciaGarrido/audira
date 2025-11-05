# Guía de Implementación Detallada: Sistema Completo de Gestión de Archivos Multimedia

Esta guía proporciona instrucciones paso a paso para implementar un sistema completo de gestión de archivos multimedia (audio e imágenes) en un proyecto similar a Audira, tanto en el backend (Java Spring Boot) como en el frontend (Flutter).

---

## Tabla de Contenidos

### Backend (Java Spring Boot)
1. [GA01-51: Upload de Archivos de Audio](#ga01-51-upload-de-archivos-de-audio-backend)
2. [GA01-52: Upload de Imágenes (Perfil, Banner, Portada)](#ga01-52-upload-de-imágenes-backend)
3. [GA01-55: Streaming de Audio con Range Requests](#ga01-55-streaming-de-audio-con-range-requests)
4. [GA01-56: Compresión de Imágenes](#ga01-56-compresión-de-imágenes)

### Frontend (Flutter)
5. [GA01-51F: Upload de Archivos de Audio - Frontend](#ga01-51f-upload-de-archivos-de-audio-frontend)
6. [GA01-52F: Upload de Imágenes - Frontend](#ga01-52f-upload-de-imágenes-frontend)
7. [GA01-55F: Reproducción de Audio con Streaming - Frontend](#ga01-55f-reproducción-de-audio-con-streaming-frontend)
8. [GA01-56F: Compresión y Optimización de Imágenes - Frontend](#ga01-56f-compresión-y-optimización-de-imágenes-frontend)

---

# BACKEND (Java Spring Boot)

---

## GA01-51: Upload de Archivos de Audio (Backend)

### Objetivo
Permitir la subida de archivos de audio en formatos MP3, WAV, FLAC, MIDI, OGG y AAC con un tamaño máximo de 50MB.

### Archivos a Crear/Modificar

#### 1. MODIFICAR: `FileStorageService.java`
**Ubicación:** `community-service/src/main/java/io/audira/community/service/FileStorageService.java`

**Qué hacer:**
1. Agregar validación para archivos de audio
2. Simplificar el método `storeFile()` para almacenamiento local únicamente
3. Agregar método `isValidAudioFile()`

**Paso a paso:**

**Paso 1:** Agregar el método de validación de audio (después del método `isValidImageFile()`, aproximadamente línea 104)

```java
public boolean isValidAudioFile(MultipartFile file) {
    // Obtener el content-type del archivo
    String contentType = file.getContentType();

    // Lista de content-types válidos para audio
    Set<String> validContentTypes = Set.of(
        "audio/mpeg",     // MP3
        "audio/mp3",      // MP3 alternativo
        "audio/wav",      // WAV
        "audio/wave",     // WAV alternativo
        "audio/x-wav",    // WAV alternativo
        "audio/flac",     // FLAC
        "audio/x-flac",   // FLAC alternativo
        "audio/midi",     // MIDI
        "audio/x-midi",   // MIDI alternativo
        "audio/ogg",      // OGG
        "audio/aac",      // AAC
        "application/octet-stream" // Genérico
    );

    // Validar por content-type
    boolean validByContentType = contentType != null &&
        validContentTypes.stream().anyMatch(contentType::equalsIgnoreCase);

    // Obtener la extensión del archivo
    String originalFilename = file.getOriginalFilename();
    String extension = "";
    if (originalFilename != null && originalFilename.contains(".")) {
        extension = originalFilename.substring(
            originalFilename.lastIndexOf(".") + 1
        ).toLowerCase();
    }

    // Lista de extensiones válidas
    Set<String> validExtensions = Set.of(
        "mp3", "wav", "flac", "midi", "mid", "ogg", "aac"
    );

    // Validar por extensión
    boolean validByExtension = validExtensions.contains(extension);

    // Retornar true si ALGUNA validación pasa (OR lógico)
    return validByContentType || validByExtension;
}
```

**¿Por qué este código?**
- Validamos TANTO por content-type COMO por extensión para mayor flexibilidad
- Algunos navegadores/clientes envían `application/octet-stream` como content-type genérico
- Usamos OR lógico: si CUALQUIERA de las validaciones pasa, aceptamos el archivo
- Soportamos múltiples variantes de content-type (ej: audio/wav, audio/wave, audio/x-wav)

**Paso 2:** Simplificar el constructor (si tenía dependencias de S3, eliminarlas)

```java
// Constructor simplificado (línea ~35)
public FileStorageService(@Value("${file.upload-dir}") String uploadDir) {
    this.uploadDir = uploadDir;
    // Ya no necesitamos S3StorageService ni campos relacionados
}
```

**Paso 3:** Simplificar el método `storeFile()` para usar solo almacenamiento local (línea ~45)

```java
public String storeFile(MultipartFile file, String subDirectory) throws IOException {
    // Crear subdirectorio si no existe
    Path subDirPath = Paths.get(uploadDir).resolve(subDirectory);
    if (!Files.exists(subDirPath)) {
        Files.createDirectories(subDirPath);
    }

    // Generar nombre único usando UUID
    String originalFilename = file.getOriginalFilename();
    String extension = "";
    if (originalFilename != null && originalFilename.contains(".")) {
        extension = originalFilename.substring(originalFilename.lastIndexOf("."));
    }
    String fileName = UUID.randomUUID().toString() + extension;

    // Guardar archivo localmente
    Path filePath = subDirPath.resolve(fileName);
    Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

    // Retornar la ruta relativa: subDirectory/fileName
    return subDirectory + "/" + fileName;
}
```

**¿Por qué este código?**
- Usamos UUID para nombres únicos y evitar conflictos
- Creamos el subdirectorio automáticamente si no existe
- Preservamos la extensión original del archivo
- Retornamos la ruta relativa para construir URLs después

---

#### 2. MODIFICAR: `FileUploadController.java`
**Ubicación:** `community-service/src/main/java/io/audira/community/controller/FileUploadController.java`

**Qué hacer:**
Agregar endpoint para subir archivos de audio

**Paso a paso:**

**Paso 1:** Agregar el endpoint de upload de audio (después de los endpoints de imágenes, aproximadamente línea 123)

```java
@PostMapping("/upload/audio")
public ResponseEntity<?> uploadAudioFile(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "songId", required = false) Long songId) {

    try {
        // Validar que el archivo no esté vacío
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "El archivo está vacío"));
        }

        // Validar formato de audio
        if (!fileStorageService.isValidAudioFile(file)) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "Formato de audio no válido. " +
                    "Formatos soportados: MP3, WAV, FLAC, MIDI, OGG, AAC"));
        }

        // Validar tamaño (50MB máximo)
        long maxSize = 50 * 1024 * 1024; // 50MB en bytes
        if (file.getSize() > maxSize) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "El archivo excede el tamaño máximo de 50MB"));
        }

        // Guardar el archivo en el subdirectorio "audio-files"
        String filePath = fileStorageService.storeFile(file, "audio-files");

        // Construir la URL completa del archivo
        String fileUrl = buildFileUrl(filePath);

        // Crear respuesta
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Audio subido exitosamente");
        response.put("filePath", filePath);
        response.put("fileUrl", fileUrl);
        if (songId != null) {
            response.put("songId", songId);
        }

        return ResponseEntity.ok(response);

    } catch (IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Map.of("error", "Error al guardar el archivo: " + e.getMessage()));
    }
}
```

**¿Por qué este código?**
- Validamos que el archivo no esté vacío primero
- Usamos `isValidAudioFile()` para validar el formato
- Verificamos el tamaño antes de guardar (ahorro de recursos)
- Guardamos en subdirectorio "audio-files" para organización
- El parámetro `songId` es opcional pero útil para asociar con una canción
- Retornamos tanto la ruta relativa como la URL completa

**Paso 2:** Simplificar el método `buildFileUrl()` (si tenía lógica de S3, eliminarla)

```java
private String buildFileUrl(String filePath) {
    // Simplemente construir la URL local
    return baseUrl + "/api/files/" + filePath;
}
```

**Paso 3:** Actualizar el valor por defecto de `baseUrl` en development

```java
@Value("${file.base-url:http://localhost:9001}")
private String baseUrl;
```

---

#### 3. MODIFICAR: `application.yml`
**Ubicación:** `community-service/src/main/resources/application.yml`

**Qué hacer:**
Configurar el directorio de uploads y límites de tamaño

```yaml
file:
  upload-dir: uploads
  base-url: http://localhost:9001

spring:
  servlet:
    multipart:
      enabled: true
      max-file-size: 50MB      # Tamaño máximo por archivo
      max-request-size: 50MB   # Tamaño máximo de la petición
```

**¿Por qué esta configuración?**
- `upload-dir`: Carpeta donde se guardan los archivos (se crea automáticamente)
- `base-url`: URL base para construir URLs de archivos
- `max-file-size`: Límite de Spring Boot para archivos individuales
- `max-request-size`: Límite total de la petición HTTP

---

#### 4. MODIFICAR: `pom.xml` (si no existe imgscalr)
**Ubicación:** `community-service/pom.xml`

**Qué hacer:**
Asegurarse de que existe la dependencia para procesamiento de imágenes (necesaria para GA01-56)

```xml
<dependency>
    <groupId>org.imgscalr</groupId>
    <artifactId>imgscalr-lib</artifactId>
    <version>4.2</version>
</dependency>
```

---

### Testing GA01-51

**Usando cURL:**

```bash
# Subir un archivo MP3
curl -X POST http://localhost:9001/api/files/upload/audio \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/ruta/a/tu/archivo.mp3" \
  -F "songId=123"

# Respuesta esperada:
# {
#   "message": "Audio subido exitosamente",
#   "filePath": "audio-files/uuid-aleatorio.mp3",
#   "fileUrl": "http://localhost:9001/api/files/audio-files/uuid-aleatorio.mp3",
#   "songId": 123
# }
```

**Usando Postman:**
1. Crear request POST a `http://localhost:9001/api/files/upload/audio`
2. En Headers: `Authorization: Bearer YOUR_TOKEN`
3. En Body → form-data:
   - Key: `file` (tipo File) → Seleccionar archivo de audio
   - Key: `songId` (tipo Text) → `123` (opcional)
4. Send

**Verificar:**
- [ ] Se crea el directorio `uploads/audio-files/` si no existía
- [ ] El archivo se guarda con nombre UUID + extensión
- [ ] La respuesta incluye fileUrl y filePath
- [ ] Formatos inválidos son rechazados
- [ ] Archivos > 50MB son rechazados

---

## GA01-52: Upload de Imágenes (Backend)

### Objetivo
Permitir la subida de tres tipos de imágenes:
- **Perfil**: Foto de perfil de usuario (máx 5MB)
- **Banner**: Banner de perfil de usuario (máx 10MB)
- **Portada**: Portada de álbum/canción (máx 10MB)

Formatos soportados: JPG, PNG, GIF, WEBP

### Archivos a Crear/Modificar

#### 1. VERIFICAR: `FileStorageService.java`

El método `isValidImageFile()` ya debería existir. Verificar que tenga este código:

```java
public boolean isValidImageFile(MultipartFile file) {
    String contentType = file.getContentType();

    Set<String> validContentTypes = Set.of(
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/gif",
        "image/webp"
    );

    boolean validByContentType = contentType != null &&
        validContentTypes.stream().anyMatch(contentType::equalsIgnoreCase);

    String originalFilename = file.getOriginalFilename();
    String extension = "";
    if (originalFilename != null && originalFilename.contains(".")) {
        extension = originalFilename.substring(
            originalFilename.lastIndexOf(".") + 1
        ).toLowerCase();
    }

    Set<String> validExtensions = Set.of("jpg", "jpeg", "png", "gif", "webp");
    boolean validByExtension = validExtensions.contains(extension);

    return validByContentType || validByExtension;
}
```

---

#### 2. MODIFICAR: `FileUploadController.java`

**Qué hacer:**
Agregar tres endpoints: uno para cada tipo de imagen

**Paso 1:** Endpoint para imagen de perfil (puede ya existir, verificar)

```java
@PostMapping("/upload/profile-image")
public ResponseEntity<?> uploadProfileImage(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "userId", required = false) Long userId) {

    try {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "El archivo está vacío"));
        }

        // Validar formato de imagen
        if (!fileStorageService.isValidImageFile(file)) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "Formato de imagen no válido. " +
                    "Formatos soportados: JPG, PNG, GIF, WEBP"));
        }

        // Validar tamaño (5MB máximo para perfil)
        long maxSize = 5 * 1024 * 1024; // 5MB
        if (file.getSize() > maxSize) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "La imagen excede el tamaño máximo de 5MB"));
        }

        // Guardar en subdirectorio "profile-images"
        String filePath = fileStorageService.storeFile(file, "profile-images");
        String fileUrl = buildFileUrl(filePath);

        // Aquí podrías actualizar el usuario si userId está presente
        // Ejemplo: userService.updateProfileImage(userId, fileUrl);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Imagen de perfil subida exitosamente");
        response.put("filePath", filePath);
        response.put("fileUrl", fileUrl);
        if (userId != null) {
            response.put("userId", userId);
        }

        return ResponseEntity.ok(response);

    } catch (IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Map.of("error", "Error al guardar la imagen: " + e.getMessage()));
    }
}
```

**Paso 2:** Endpoint para banner (puede ya existir, verificar)

```java
@PostMapping("/upload/banner-image")
public ResponseEntity<?> uploadBannerImage(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "userId", required = false) Long userId) {

    try {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "El archivo está vacío"));
        }

        if (!fileStorageService.isValidImageFile(file)) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "Formato de imagen no válido. " +
                    "Formatos soportados: JPG, PNG, GIF, WEBP"));
        }

        // Validar tamaño (10MB máximo para banner)
        long maxSize = 10 * 1024 * 1024; // 10MB
        if (file.getSize() > maxSize) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "La imagen excede el tamaño máximo de 10MB"));
        }

        // Guardar en subdirectorio "banner-images"
        String filePath = fileStorageService.storeFile(file, "banner-images");
        String fileUrl = buildFileUrl(filePath);

        // Aquí podrías actualizar el usuario si userId está presente
        // Ejemplo: userService.updateBannerImage(userId, fileUrl);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Banner subido exitosamente");
        response.put("filePath", filePath);
        response.put("fileUrl", fileUrl);
        if (userId != null) {
            response.put("userId", userId);
        }

        return ResponseEntity.ok(response);

    } catch (IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Map.of("error", "Error al guardar el banner: " + e.getMessage()));
    }
}
```

**Paso 3:** Endpoint para portada de álbum/canción (nuevo)

```java
@PostMapping("/upload/cover-image")
public ResponseEntity<?> uploadCoverImage(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "productId", required = false) Long productId) {

    try {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "El archivo está vacío"));
        }

        if (!fileStorageService.isValidImageFile(file)) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "Formato de imagen no válido. " +
                    "Formatos soportados: JPG, PNG, GIF, WEBP"));
        }

        // Validar tamaño (10MB máximo)
        long maxSize = 10 * 1024 * 1024; // 10MB
        if (file.getSize() > maxSize) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "La imagen excede el tamaño máximo de 10MB"));
        }

        // Guardar en subdirectorio "cover-images"
        String filePath = fileStorageService.storeFile(file, "cover-images");
        String fileUrl = buildFileUrl(filePath);

        // NOTA: A diferencia de profile/banner, NO actualizamos ningún modelo aquí
        // El frontend deberá llamar al endpoint de update de Song/Album después

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Portada subida exitosamente");
        response.put("filePath", filePath);
        response.put("fileUrl", fileUrl);
        if (productId != null) {
            response.put("productId", productId);
        }

        return ResponseEntity.ok(response);

    } catch (IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Map.of("error", "Error al guardar la portada: " + e.getMessage()));
    }
}
```

**¿Cuál es la diferencia entre estos endpoints?**

| Endpoint | Subdirectorio | Tamaño Máx | Actualiza Modelo |
|----------|---------------|------------|------------------|
| `/upload/profile-image` | profile-images | 5MB | Sí (User) |
| `/upload/banner-image` | banner-images | 10MB | Sí (User) |
| `/upload/cover-image` | cover-images | 10MB | No (manual) |

- Los endpoints de perfil/banner pueden actualizar directamente el modelo User
- El endpoint de cover NO actualiza nada: retorna la URL para que el frontend la use al crear/actualizar Song/Album

---

### Testing GA01-52

```bash
# Subir imagen de perfil
curl -X POST http://localhost:9001/api/files/upload/profile-image \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/ruta/a/foto-perfil.jpg" \
  -F "userId=456"

# Subir banner
curl -X POST http://localhost:9001/api/files/upload/banner-image \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/ruta/a/banner.png" \
  -F "userId=456"

# Subir portada
curl -X POST http://localhost:9001/api/files/upload/cover-image \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/ruta/a/album-cover.jpg" \
  -F "productId=789"
```

**Verificar:**
- [ ] Se crean los directorios `profile-images/`, `banner-images/`, `cover-images/`
- [ ] Tamaños son respetados (5MB perfil, 10MB banner/cover)
- [ ] Formatos inválidos son rechazados
- [ ] Las URLs retornadas son accesibles

---

## GA01-55: Streaming de Audio con Range Requests

### Objetivo
Implementar un endpoint que sirva archivos de audio soportando HTTP Range Requests (RFC 7233), permitiendo:
- Reproducción progresiva sin descargar todo el archivo
- Seek/scrub en el reproductor de audio
- Menor uso de ancho de banda

### Archivos a Crear/Modificar

#### 1. CREAR: `FileServeController.java` ⭐ NUEVO
**Ubicación:** `community-service/src/main/java/io/audira/community/controller/FileServeController.java`

**Qué hacer:**
Crear un controlador completamente nuevo para servir archivos con soporte de Range Requests

```java
package io.audira.community.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/files")
@CrossOrigin(origins = "*")
public class FileServeController {

    @Value("${file.upload-dir}")
    private String uploadDir;

    /**
     * Endpoint principal para servir archivos
     * Soporta HTTP Range Requests para audio streaming
     */
    @GetMapping("/{subDirectory}/{fileName:.+}")
    public ResponseEntity<Resource> serveFile(
            @PathVariable String subDirectory,
            @PathVariable String fileName,
            @RequestHeader(value = "Range", required = false) String range) {

        try {
            // Construir la ruta completa del archivo
            Path filePath = Paths.get(uploadDir)
                .resolve(subDirectory)
                .resolve(fileName)
                .normalize();

            // Verificar que el archivo existe
            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            // Crear el recurso
            Resource resource = new UrlResource(filePath.toUri());

            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }

            // Determinar el content-type
            String contentType = determineContentType(fileName);

            // Obtener el tamaño del archivo
            long fileLength = Files.size(filePath);

            // Si hay un header Range y es un archivo de audio, manejar Range Request
            if (range != null && isAudioFile(fileName)) {
                return handleRangeRequest(resource, filePath, range, contentType, fileLength);
            }

            // Si no hay Range header, servir el archivo completo
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(fileLength))
                .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                .body(resource);

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Maneja peticiones con Range header (206 Partial Content)
     */
    private ResponseEntity<Resource> handleRangeRequest(
            Resource resource,
            Path filePath,
            String range,
            String contentType,
            long fileLength) throws IOException {

        // Parsear el Range header: "bytes=start-end"
        if (!range.startsWith("bytes=")) {
            return ResponseEntity.status(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE)
                .header(HttpHeaders.CONTENT_RANGE, "bytes */" + fileLength)
                .build();
        }

        String[] ranges = range.substring(6).split("-");
        long start = 0;
        long end = fileLength - 1;

        // Parsear start
        if (ranges.length > 0 && !ranges[0].isEmpty()) {
            start = Long.parseLong(ranges[0]);
        }

        // Parsear end
        if (ranges.length > 1 && !ranges[1].isEmpty()) {
            end = Long.parseLong(ranges[1]);
        }

        // Validar el rango
        if (start > end || start < 0 || end >= fileLength) {
            return ResponseEntity.status(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE)
                .header(HttpHeaders.CONTENT_RANGE, "bytes */" + fileLength)
                .build();
        }

        long contentLength = end - start + 1;

        // Crear InputStreamResource para el rango específico
        var inputStream = Files.newInputStream(filePath);
        inputStream.skip(start);

        org.springframework.core.io.InputStreamResource inputStreamResource =
            new org.springframework.core.io.InputStreamResource(inputStream);

        // Retornar 206 Partial Content
        return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
            .contentType(MediaType.parseMediaType(contentType))
            .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(contentLength))
            .header(HttpHeaders.CONTENT_RANGE,
                String.format("bytes %d-%d/%d", start, end, fileLength))
            .header(HttpHeaders.ACCEPT_RANGES, "bytes")
            .body(inputStreamResource);
    }

    /**
     * Determina el content-type basado en la extensión del archivo
     */
    private String determineContentType(String fileName) {
        String extension = "";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = fileName.substring(dotIndex + 1).toLowerCase();
        }

        // Audio types
        switch (extension) {
            case "mp3": return "audio/mpeg";
            case "wav": return "audio/wav";
            case "flac": return "audio/flac";
            case "midi":
            case "mid": return "audio/midi";
            case "ogg": return "audio/ogg";
            case "aac": return "audio/aac";

            // Image types
            case "jpg":
            case "jpeg": return "image/jpeg";
            case "png": return "image/png";
            case "gif": return "image/gif";
            case "webp": return "image/webp";

            default: return "application/octet-stream";
        }
    }

    /**
     * Verifica si el archivo es de audio
     */
    private boolean isAudioFile(String fileName) {
        String extension = "";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = fileName.substring(dotIndex + 1).toLowerCase();
        }
        return extension.matches("mp3|wav|flac|midi|mid|ogg|aac");
    }
}
```

**¿Qué hace este código paso a paso?**

1. **Recibe la petición** con subdirectorio, nombre de archivo, y opcionalmente Range header
2. **Construye la ruta** del archivo en el sistema local
3. **Verifica existencia** y permisos de lectura
4. **Detecta el tipo de archivo** por extensión
5. **Si NO hay Range header**: Retorna el archivo completo (200 OK)
6. **Si HAY Range header y es audio**:
   - Parsea el rango solicitado (ej: "bytes=0-1023")
   - Valida que el rango sea válido
   - Lee solo esa porción del archivo
   - Retorna 206 Partial Content con headers apropiados

**Headers importantes en la respuesta:**

| Header | Valor Ejemplo | Significado |
|--------|---------------|-------------|
| Accept-Ranges | bytes | El servidor acepta peticiones de rangos |
| Content-Range | bytes 0-1023/5000000 | Rango enviado / tamaño total |
| Content-Length | 1024 | Bytes en esta respuesta |
| Content-Type | audio/mpeg | Tipo MIME del archivo |

---

### Testing GA01-55

**Test 1: Petición completa (sin Range)**

```bash
curl -I http://localhost:9001/api/files/audio-files/uuid-archivo.mp3

# Respuesta esperada:
# HTTP/1.1 200 OK
# Content-Type: audio/mpeg
# Content-Length: 5000000
# Accept-Ranges: bytes
```

**Test 2: Petición con Range (primeros 1KB)**

```bash
curl -H "Range: bytes=0-1023" \
  http://localhost:9001/api/files/audio-files/uuid-archivo.mp3 \
  --output parte1.mp3

# Respuesta esperada:
# HTTP/1.1 206 Partial Content
# Content-Type: audio/mpeg
# Content-Length: 1024
# Content-Range: bytes 0-1023/5000000
# Accept-Ranges: bytes
```

**Test 3: Petición con Range (segundo KB)**

```bash
curl -H "Range: bytes=1024-2047" \
  http://localhost:9001/api/files/audio-files/uuid-archivo.mp3 \
  --output parte2.mp3

# Respuesta esperada:
# HTTP/1.1 206 Partial Content
# Content-Range: bytes 1024-2047/5000000
```

**Test 4: Rango inválido**

```bash
curl -I -H "Range: bytes=5000000-6000000" \
  http://localhost:9001/api/files/audio-files/uuid-archivo.mp3

# Respuesta esperada:
# HTTP/1.1 416 Range Not Satisfiable
# Content-Range: bytes */5000000
```

**Verificar:**
- [ ] Peticiones sin Range retornan 200 OK
- [ ] Peticiones con Range retornan 206 Partial Content
- [ ] El header Content-Range tiene el formato correcto
- [ ] Rangos inválidos retornan 416
- [ ] El reproductor de audio puede hacer seek correctamente

---

## GA01-56: Compresión de Imágenes

### Objetivo
Implementar endpoints para comprimir y optimizar imágenes, con control de calidad y dimensiones.

### Archivos a Crear/Modificar

#### 1. CREAR: `ImageCompressionService.java` ⭐ NUEVO
**Ubicación:** `community-service/src/main/java/io/audira/community/service/ImageCompressionService.java`

**Qué hacer:**
Crear un servicio para comprimir y redimensionar imágenes usando la librería imgscalr

```java
package io.audira.community.service;

import org.imgscalr.Scalr;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;

@Service
public class ImageCompressionService {

    /**
     * Comprime una imagen con la calidad especificada
     * @param file Archivo de imagen
     * @param quality Calidad (0.0 a 1.0, donde 1.0 es la máxima calidad)
     * @return InputStream de la imagen comprimida
     */
    public InputStream compressImage(MultipartFile file, float quality) throws IOException {
        if (quality < 0.0f || quality > 1.0f) {
            throw new IllegalArgumentException("La calidad debe estar entre 0.0 y 1.0");
        }

        // Leer la imagen original
        BufferedImage originalImage = ImageIO.read(file.getInputStream());
        if (originalImage == null) {
            throw new IOException("No se pudo leer la imagen");
        }

        // Obtener el formato de la imagen
        String formatName = getFormatName(file.getOriginalFilename());

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        // Para JPEG, usar compresión con calidad
        if ("jpg".equals(formatName) || "jpeg".equals(formatName)) {
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpeg");
            if (!writers.hasNext()) {
                throw new IOException("No hay escritores disponibles para JPEG");
            }

            ImageWriter writer = writers.next();
            ImageWriteParam param = writer.getDefaultWriteParam();

            // Configurar la compresión
            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(quality);
            }

            // Escribir la imagen comprimida
            try (ImageOutputStream ios = ImageIO.createImageOutputStream(outputStream)) {
                writer.setOutput(ios);
                writer.write(null, new IIOImage(originalImage, null, null), param);
                writer.dispose();
            }
        } else {
            // Para otros formatos (PNG, GIF, etc.), usar escritura estándar
            ImageIO.write(originalImage, formatName, outputStream);
        }

        return new ByteArrayInputStream(outputStream.toByteArray());
    }

    /**
     * Redimensiona una imagen manteniendo la proporción
     * @param file Archivo de imagen
     * @param maxWidth Ancho máximo
     * @param maxHeight Alto máximo
     * @return InputStream de la imagen redimensionada
     */
    public InputStream resizeImage(MultipartFile file, int maxWidth, int maxHeight)
            throws IOException {

        BufferedImage originalImage = ImageIO.read(file.getInputStream());
        if (originalImage == null) {
            throw new IOException("No se pudo leer la imagen");
        }

        // Redimensionar usando imgscalr (mantiene proporción automáticamente)
        BufferedImage resizedImage = Scalr.resize(
            originalImage,
            Scalr.Method.QUALITY,        // Usar algoritmo de alta calidad
            Scalr.Mode.FIT_TO_WIDTH,     // Ajustar al ancho, manteniendo proporción
            maxWidth,
            maxHeight,
            Scalr.OP_ANTIALIAS           // Aplicar antialiasing
        );

        // Convertir a InputStream
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        String formatName = getFormatName(file.getOriginalFilename());
        ImageIO.write(resizedImage, formatName, outputStream);

        return new ByteArrayInputStream(outputStream.toByteArray());
    }

    /**
     * Comprime Y redimensiona una imagen
     * @param file Archivo de imagen
     * @param maxWidth Ancho máximo
     * @param maxHeight Alto máximo
     * @param quality Calidad de compresión (0.0 a 1.0)
     * @return InputStream de la imagen procesada
     */
    public InputStream compressAndResize(
            MultipartFile file,
            int maxWidth,
            int maxHeight,
            float quality) throws IOException {

        // Primero redimensionar
        BufferedImage originalImage = ImageIO.read(file.getInputStream());
        BufferedImage resizedImage = Scalr.resize(
            originalImage,
            Scalr.Method.QUALITY,
            Scalr.Mode.FIT_TO_WIDTH,
            maxWidth,
            maxHeight,
            Scalr.OP_ANTIALIAS
        );

        // Luego comprimir
        String formatName = getFormatName(file.getOriginalFilename());
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        if ("jpg".equals(formatName) || "jpeg".equals(formatName)) {
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpeg");
            ImageWriter writer = writers.next();
            ImageWriteParam param = writer.getDefaultWriteParam();

            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(quality);
            }

            try (ImageOutputStream ios = ImageIO.createImageOutputStream(outputStream)) {
                writer.setOutput(ios);
                writer.write(null, new IIOImage(resizedImage, null, null), param);
                writer.dispose();
            }
        } else {
            ImageIO.write(resizedImage, formatName, outputStream);
        }

        return new ByteArrayInputStream(outputStream.toByteArray());
    }

    /**
     * Obtiene el nombre del formato de la imagen
     */
    private String getFormatName(String filename) {
        String extension = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
        return extension.equals("jpg") ? "jpeg" : extension;
    }
}
```

**¿Qué hace este servicio?**

1. **compressImage()**: Reduce el tamaño del archivo ajustando la calidad JPEG
2. **resizeImage()**: Cambia las dimensiones manteniendo proporción
3. **compressAndResize()**: Combina ambas operaciones para máxima optimización

**Algoritmos usados:**
- `Scalr.Method.QUALITY`: Algoritmo Lanczos3 (alta calidad, más lento)
- `Scalr.Mode.FIT_TO_WIDTH`: Ajusta al ancho manteniendo aspect ratio
- `Scalr.OP_ANTIALIAS`: Suaviza bordes

---

#### 2. MODIFICAR: `FileUploadController.java`

**Qué hacer:**
Agregar endpoints para compresión de imágenes

**Paso 1:** Inyectar ImageCompressionService

```java
@Autowired
private ImageCompressionService imageCompressionService;
```

**Paso 2:** Endpoint para comprimir y retornar imagen binaria

```java
@PostMapping("/compress/image")
public ResponseEntity<byte[]> compressImage(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "quality", defaultValue = "0.8") float quality,
        @RequestParam(value = "maxWidth", required = false) Integer maxWidth,
        @RequestParam(value = "maxHeight", required = false) Integer maxHeight) {

    try {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        InputStream compressedStream;

        // Si se especifican dimensiones, redimensionar y comprimir
        if (maxWidth != null && maxHeight != null) {
            compressedStream = imageCompressionService.compressAndResize(
                file, maxWidth, maxHeight, quality
            );
        } else {
            // Solo comprimir
            compressedStream = imageCompressionService.compressImage(file, quality);
        }

        // Leer todos los bytes
        byte[] imageBytes = compressedStream.readAllBytes();

        // Determinar content-type
        String contentType = file.getContentType();
        if (contentType == null) {
            contentType = "image/jpeg";
        }

        // Retornar la imagen comprimida como respuesta binaria
        return ResponseEntity.ok()
            .contentType(MediaType.parseMediaType(contentType))
            .body(imageBytes);

    } catch (IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
}
```

**Paso 3:** Endpoint para obtener estadísticas de compresión (sin guardar)

```java
@PostMapping("/optimize/image")
public ResponseEntity<?> optimizeImage(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "quality", defaultValue = "0.8") float quality,
        @RequestParam(value = "maxWidth", required = false) Integer maxWidth,
        @RequestParam(value = "maxHeight", required = false) Integer maxHeight) {

    try {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "El archivo está vacío"));
        }

        long originalSize = file.getSize();

        InputStream compressedStream;
        if (maxWidth != null && maxHeight != null) {
            compressedStream = imageCompressionService.compressAndResize(
                file, maxWidth, maxHeight, quality
            );
        } else {
            compressedStream = imageCompressionService.compressImage(file, quality);
        }

        byte[] compressedBytes = compressedStream.readAllBytes();
        long compressedSize = compressedBytes.length;

        // Calcular ratio de compresión
        double compressionRatio =
            ((double) (originalSize - compressedSize) / originalSize) * 100;

        Map<String, Object> response = new HashMap<>();
        response.put("originalSize", originalSize);
        response.put("compressedSize", compressedSize);
        response.put("compressionRatio",
            String.format("%.2f%%", compressionRatio));
        response.put("message",
            String.format("Imagen optimizada: %d KB → %d KB (%.2f%% reducción)",
                originalSize / 1024,
                compressedSize / 1024,
                compressionRatio));

        return ResponseEntity.ok(response);

    } catch (IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Map.of("error", "Error al procesar imagen: " + e.getMessage()));
    }
}
```

**¿Cuál es la diferencia entre estos endpoints?**

| Endpoint | Qué hace | Retorna | Guarda archivo |
|----------|----------|---------|----------------|
| `/compress/image` | Comprime la imagen | Imagen binaria | No |
| `/optimize/image` | Calcula estadísticas | JSON con stats | No |

---

### Testing GA01-56

**Test 1: Comprimir imagen**

```bash
curl -X POST http://localhost:9001/api/files/compress/image \
  -F "file=@imagen-grande.jpg" \
  -F "quality=0.7" \
  --output imagen-comprimida.jpg
```

**Test 2: Comprimir y redimensionar**

```bash
curl -X POST http://localhost:9001/api/files/compress/image \
  -F "file=@imagen-grande.jpg" \
  -F "quality=0.8" \
  -F "maxWidth=800" \
  -F "maxHeight=600" \
  --output imagen-optimizada.jpg
```

**Test 3: Obtener estadísticas**

```bash
curl -X POST http://localhost:9001/api/files/optimize/image \
  -F "file=@imagen-grande.jpg" \
  -F "quality=0.7"

# Respuesta esperada:
# {
#   "originalSize": 2500000,
#   "compressedSize": 800000,
#   "compressionRatio": "68.00%",
#   "message": "Imagen optimizada: 2441 KB → 781 KB (68.00% reducción)"
# }
```

**Verificar:**
- [ ] La imagen comprimida es más pequeña que la original
- [ ] La calidad visual es aceptable
- [ ] Las dimensiones son correctas si se especificó maxWidth/maxHeight
- [ ] El endpoint de estadísticas retorna JSON correctamente

---

# FRONTEND (Flutter)

---

## GA01-51F: Upload de Archivos de Audio (Frontend)

### Objetivo
Crear un widget y servicio en Flutter para seleccionar y subir archivos de audio al backend.

### Archivos a Crear/Modificar

#### 1. MODIFICAR: `lib/core/api/api_client.dart`

**Qué hacer:**
Agregar método para upload multipart/form-data

**Paso 1:** Agregar imports necesarios (al inicio del archivo)

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../config/constants.dart';
```

**Paso 2:** Agregar método postMultipart (después del método patch, aproximadamente línea 230)

```dart
/// Upload file with multipart/form-data
Future<ApiResponse<T>> postMultipart<T>(
  String endpoint, {
  required File file,
  required String fileFieldName,
  Map<String, String>? fields,
  Map<String, String>? queryParameters,
  bool requiresAuth = true,
  String? contentType,
}) async {
  try {
    String? token;
    if (requiresAuth) {
      token = await _getAuthToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          error: AppConstants.errorUnauthorizedMessage,
          statusCode: 401,
        );
      }
    }

    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParameters);

    final request = http.MultipartRequest('POST', uri);

    // Add auth header if needed
    if (requiresAuth && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add the file
    final mimeType = contentType ?? _getMimeType(file.path);
    final mimeTypeData = mimeType.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        fileFieldName,
        file.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ),
    );

    // Add additional fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse<T>(response);
  } catch (e) {
    return ApiResponse(
      success: false,
      error: '${AppConstants.errorNetworkMessage}: $e',
    );
  }
}

/// Get MIME type from file extension
String _getMimeType(String path) {
  final ext = path.split('.').last.toLowerCase();

  // Audio types
  if (ext == 'mp3') return 'audio/mpeg';
  if (ext == 'wav') return 'audio/wav';
  if (ext == 'flac') return 'audio/flac';
  if (ext == 'midi' || ext == 'mid') return 'audio/midi';
  if (ext == 'ogg') return 'audio/ogg';
  if (ext == 'aac') return 'audio/aac';

  // Image types
  if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
  if (ext == 'png') return 'image/png';
  if (ext == 'gif') return 'image/gif';
  if (ext == 'webp') return 'image/webp';

  return 'application/octet-stream';
}
```

**¿Qué hace este código?**
- Crea una petición multipart/form-data para uploads
- Agrega automáticamente el token JWT si es necesario
- Detecta el MIME type por extensión del archivo
- Permite agregar campos adicionales (como songId, userId, etc.)
- Maneja errores de red y autenticación

---

#### 2. CREAR: `lib/core/models/file_upload_response.dart` ⭐ NUEVO

**Qué hacer:**
Crear modelos para las respuestas del backend

```dart
class FileUploadResponse {
  final String? fileUrl;
  final String? filePath;
  final int? songId;
  final int? productId;
  final String? message;

  FileUploadResponse({
    this.fileUrl,
    this.filePath,
    this.songId,
    this.productId,
    this.message,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      fileUrl: json['fileUrl'] as String?,
      filePath: json['filePath'] as String?,
      songId: json['songId'] as int?,
      productId: json['productId'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileUrl': fileUrl,
      'filePath': filePath,
      'songId': songId,
      'productId': productId,
      'message': message,
    };
  }
}

class ImageCompressionStats {
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final String message;

  ImageCompressionStats({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.message,
  });

  factory ImageCompressionStats.fromJson(Map<String, dynamic> json) {
    return ImageCompressionStats(
      originalSize: json['originalSize'] as int,
      compressedSize: json['compressedSize'] as int,
      compressionRatio: (json['compressionRatio'] as num).toDouble(),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': compressionRatio,
      'message': message,
    };
  }

  String get originalSizeFormatted => _formatBytes(originalSize);
  String get compressedSizeFormatted => _formatBytes(compressedSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
```

**¿Por qué estos modelos?**
- `FileUploadResponse`: Mapea exactamente la respuesta del backend
- `ImageCompressionStats`: Para estadísticas de compresión
- Los campos son opcionales (`?`) porque varían según el endpoint
- Incluye métodos helper como `originalSizeFormatted` para UI

---

#### 3. MODIFICAR: `lib/config/constants.dart`

**Qué hacer:**
Agregar constantes para endpoints de archivos

```dart
// File endpoints (agregar después de paymentsUrl)
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

#### 4. CREAR: `lib/core/api/services/file_upload_service.dart` ⭐ NUEVO

**Qué hacer:**
Crear servicio completo para upload de archivos

```dart
import 'dart:io';

import '../api_client.dart';
import '../../../config/constants.dart';
import '../../models/file_upload_response.dart';

class FileUploadService {
  final ApiClient _apiClient = ApiClient();

  /// Upload an audio file
  /// Supports: MP3, WAV, FLAC, MIDI, OGG, AAC
  /// Max size: 50MB
  Future<ApiResponse<FileUploadResponse>> uploadAudioFile(
    File audioFile, {
    int? songId,
  }) async {
    final fields = <String, String>{};
    if (songId != null) {
      fields['songId'] = songId.toString();
    }

    final response = await _apiClient.postMultipart(
      AppConstants.fileUploadAudioUrl,
      file: audioFile,
      fileFieldName: 'file',
      fields: fields,
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      try {
        return ApiResponse(
          success: true,
          data: FileUploadResponse.fromJson(
            response.data as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          error: 'Error al parsear respuesta: $e',
        );
      }
    }
    return ApiResponse(success: false, error: response.error);
  }

  /// Build the complete URL for a file
  String getFileUrl(String filePath) {
    return '${AppConstants.apiGatewayUrl}${AppConstants.fileServeUrl}/$filePath';
  }

  /// Check if a file is a valid audio file
  bool isValidAudioFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'flac', 'midi', 'mid', 'ogg', 'aac'].contains(ext);
  }

  /// Get the max allowed size for audio files (in bytes)
  int get maxAudioFileSize => 50 * 1024 * 1024; // 50MB
}
```

**¿Qué hace este servicio?**
- Encapsula la lógica de upload de audio
- Valida formatos y tamaños antes de subir
- Construye URLs completas para archivos
- Maneja errores de parsing

---

#### 5. CREAR: `lib/features/common/widgets/audio_file_picker.dart` ⭐ NUEVO

**Qué hacer:**
Crear widget reutilizable para seleccionar y subir audio

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/theme.dart';
import '../../../core/api/services/file_upload_service.dart';
import '../../../core/models/file_upload_response.dart';

/// Widget for picking and uploading audio files
/// Supports: MP3, WAV, FLAC, MIDI, OGG, AAC
class AudioFilePicker extends StatefulWidget {
  final Function(FileUploadResponse) onUploadComplete;
  final Function(String)? onUploadError;
  final int? songId;
  final String buttonText;
  final bool showProgress;

  const AudioFilePicker({
    super.key,
    required this.onUploadComplete,
    this.onUploadError,
    this.songId,
    this.buttonText = 'Seleccionar Audio',
    this.showProgress = true,
  });

  @override
  State<AudioFilePicker> createState() => _AudioFilePickerState();
}

class _AudioFilePickerState extends State<AudioFilePicker> {
  final FileUploadService _fileUploadService = FileUploadService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  File? _selectedFile;

  Future<void> _pickAndUploadAudio() async {
    try {
      // Pick audio file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'flac', 'midi', 'mid', 'ogg', 'aac'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.first.path!);
      _selectedFile = file;

      // Validate file
      if (!_fileUploadService.isValidAudioFile(file)) {
        _showError('Formato de audio no válido');
        return;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > _fileUploadService.maxAudioFileSize) {
        _showError('El archivo excede el tamaño máximo de 50MB');
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Upload file
      final response = await _fileUploadService.uploadAudioFile(
        file,
        songId: widget.songId,
      );

      if (response.success && response.data != null) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 1.0;
        });

        widget.onUploadComplete(response.data!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Audio subido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isUploading = false;
        });

        final error = response.error ?? 'Error al subir audio';
        _showError(error);
        widget.onUploadError?.call(error);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      final error = 'Error al procesar audio: $e';
      _showError(error);
      widget.onUploadError?.call(error);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUploadAudio,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.audio_file),
          label: Text(
            _isUploading ? 'Subiendo...' : widget.buttonText,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        if (widget.showProgress && _isUploading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppTheme.textGrey.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryPurple,
            ),
          ),
        ],
        if (_selectedFile != null && !_isUploading) ...[
          const SizedBox(height: 8),
          Text(
            'Archivo: ${_selectedFile!.path.split('/').last}',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
```

**¿Cómo usar este widget?**

```dart
// En cualquier pantalla:
AudioFilePicker(
  songId: 123,
  buttonText: 'Subir Audio de Canción',
  onUploadComplete: (response) {
    // El audio se subió exitosamente
    print('URL: ${response.fileUrl}');

    // Aquí puedes actualizar tu estado, navegar, etc.
    setState(() {
      audioUrl = response.fileUrl;
    });
  },
  onUploadError: (error) {
    // Hubo un error
    print('Error: $error');
  },
)
```

**Características del widget:**
- ✅ Validación automática de formato
- ✅ Validación de tamaño (50MB)
- ✅ Indicador de progreso
- ✅ Muestra nombre del archivo seleccionado
- ✅ SnackBars para feedback visual
- ✅ Callback para éxito y error
- ✅ Personalizable (texto del botón, mostrar progreso, etc.)

---

### Testing GA01-51F

**Test manual:**
1. Crear una pantalla de prueba con el widget `AudioFilePicker`
2. Seleccionar un archivo MP3 válido → Debe subir correctamente
3. Seleccionar un archivo > 50MB → Debe mostrar error
4. Seleccionar un archivo .txt → Debe mostrar error de formato
5. Verificar que el callback `onUploadComplete` recibe la URL correcta

---

## GA01-52F: Upload de Imágenes (Frontend)

### Objetivo
Crear widget para seleccionar y subir imágenes de tres tipos: perfil, banner, y portada.

### Archivos a Crear/Modificar

#### 1. MODIFICAR: `lib/core/api/services/file_upload_service.dart`

**Qué hacer:**
Agregar métodos para upload de imágenes al servicio existente

```dart
/// Upload a profile image
/// Supports: JPG, PNG, GIF, WEBP
/// Max size: 5MB
Future<ApiResponse<FileUploadResponse>> uploadProfileImage(
  File imageFile, {
  int? userId,
}) async {
  final fields = <String, String>{};
  if (userId != null) {
    fields['userId'] = userId.toString();
  }

  final response = await _apiClient.postMultipart(
    AppConstants.fileUploadProfileImageUrl,
    file: imageFile,
    fileFieldName: 'file',
    fields: fields,
    requiresAuth: true,
  );

  if (response.success && response.data != null) {
    try {
      return ApiResponse(
        success: true,
        data: FileUploadResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al parsear respuesta: $e',
      );
    }
  }
  return ApiResponse(success: false, error: response.error);
}

/// Upload a banner image
/// Supports: JPG, PNG, GIF, WEBP
/// Max size: 10MB
Future<ApiResponse<FileUploadResponse>> uploadBannerImage(
  File imageFile, {
  int? userId,
}) async {
  final fields = <String, String>{};
  if (userId != null) {
    fields['userId'] = userId.toString();
  }

  final response = await _apiClient.postMultipart(
    AppConstants.fileUploadBannerImageUrl,
    file: imageFile,
    fileFieldName: 'file',
    fields: fields,
    requiresAuth: true,
  );

  if (response.success && response.data != null) {
    try {
      return ApiResponse(
        success: true,
        data: FileUploadResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al parsear respuesta: $e',
      );
    }
  }
  return ApiResponse(success: false, error: response.error);
}

/// Upload a cover image (for albums, songs, etc.)
/// Supports: JPG, PNG, GIF, WEBP
/// Max size: 10MB
Future<ApiResponse<FileUploadResponse>> uploadCoverImage(
  File imageFile, {
  int? productId,
}) async {
  final fields = <String, String>{};
  if (productId != null) {
    fields['productId'] = productId.toString();
  }

  final response = await _apiClient.postMultipart(
    AppConstants.fileUploadCoverImageUrl,
    file: imageFile,
    fileFieldName: 'file',
    fields: fields,
    requiresAuth: true,
  );

  if (response.success && response.data != null) {
    try {
      return ApiResponse(
        success: true,
        data: FileUploadResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al parsear respuesta: $e',
      );
    }
  }
  return ApiResponse(success: false, error: response.error);
}

/// Check if a file is a valid image file
bool isValidImageFile(File file) {
  final ext = file.path.split('.').last.toLowerCase();
  return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
}

/// Get the max allowed size for profile images (in bytes)
int get maxProfileImageSize => 5 * 1024 * 1024; // 5MB

/// Get the max allowed size for banner/cover images (in bytes)
int get maxBannerImageSize => 10 * 1024 * 1024; // 10MB
```

---

#### 2. CREAR: `lib/features/common/widgets/image_file_picker.dart` ⭐ NUEVO

**Qué hacer:**
Crear widget para seleccionar y subir imágenes

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/services/file_upload_service.dart';
import '../../../core/models/file_upload_response.dart';

enum ImageUploadType {
  profile,
  banner,
  cover,
}

/// Widget for picking and uploading image files
/// Supports: JPG, PNG, GIF, WEBP
class ImageFilePicker extends StatefulWidget {
  final ImageUploadType uploadType;
  final Function(FileUploadResponse) onUploadComplete;
  final Function(String)? onUploadError;
  final int? userId;
  final int? productId;
  final String? buttonText;
  final bool showPreview;
  final double? previewHeight;

  const ImageFilePicker({
    super.key,
    required this.uploadType,
    required this.onUploadComplete,
    this.onUploadError,
    this.userId,
    this.productId,
    String? buttonText,
    this.showPreview = true,
    this.previewHeight,
  }) : buttonText = buttonText ?? _getDefaultButtonText(uploadType);

  static String _getDefaultButtonText(ImageUploadType type) {
    switch (type) {
      case ImageUploadType.profile:
        return 'Seleccionar Foto de Perfil';
      case ImageUploadType.banner:
        return 'Seleccionar Banner';
      case ImageUploadType.cover:
        return 'Seleccionar Portada';
    }
  }

  @override
  State<ImageFilePicker> createState() => _ImageFilePickerState();
}

class _ImageFilePickerState extends State<ImageFilePicker> {
  final FileUploadService _fileUploadService = FileUploadService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: widget.uploadType == ImageUploadType.profile ? 1024 : 2048,
        maxHeight: widget.uploadType == ImageUploadType.profile ? 1024 : 2048,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final file = File(pickedFile.path);
      _selectedImage = file;

      // Validate file
      if (!_fileUploadService.isValidImageFile(file)) {
        _showError('Formato de imagen no válido');
        return;
      }

      // Check file size
      final fileSize = await file.length();
      final maxSize = widget.uploadType == ImageUploadType.profile
          ? _fileUploadService.maxProfileImageSize
          : _fileUploadService.maxBannerImageSize;

      if (fileSize > maxSize) {
        final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(0);
        _showError('El archivo excede el tamaño máximo de ${maxSizeMB}MB');
        return;
      }

      setState(() {
        _isUploading = true;
      });

      // Upload file based on type
      late ApiResponse<FileUploadResponse> response;

      switch (widget.uploadType) {
        case ImageUploadType.profile:
          response = await _fileUploadService.uploadProfileImage(
            file,
            userId: widget.userId,
          );
          break;
        case ImageUploadType.banner:
          response = await _fileUploadService.uploadBannerImage(
            file,
            userId: widget.userId,
          );
          break;
        case ImageUploadType.cover:
          response = await _fileUploadService.uploadCoverImage(
            file,
            productId: widget.productId,
          );
          break;
      }

      setState(() {
        _isUploading = false;
      });

      if (response.success && response.data != null) {
        setState(() {
          _uploadedImageUrl = response.data!.fileUrl;
        });

        widget.onUploadComplete(response.data!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen subida exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = response.error ?? 'Error al subir imagen';
        _showError(error);
        widget.onUploadError?.call(error);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      final error = 'Error al procesar imagen: $e';
      _showError(error);
      widget.onUploadError?.call(error);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppTheme.primaryPurple),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryPurple),
                title: const Text('Seleccionar de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showPreview && (_selectedImage != null || _uploadedImageUrl != null)) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: widget.previewHeight ?? 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : _uploadedImageUrl != null
                    ? Image.network(
                        _uploadedImageUrl!,
                        height: widget.previewHeight ?? 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: widget.previewHeight ?? 200,
                            color: AppTheme.backgroundBlack,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: widget.previewHeight ?? 200,
                            color: AppTheme.backgroundBlack,
                            child: const Icon(Icons.error),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _showImageSourceDialog,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.image),
          label: Text(
            _isUploading ? 'Subiendo...' : widget.buttonText!,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
```

**¿Cómo usar este widget?**

```dart
// Imagen de perfil
ImageFilePicker(
  uploadType: ImageUploadType.profile,
  userId: currentUserId,
  showPreview: true,
  onUploadComplete: (response) {
    setState(() {
      profileImageUrl = response.fileUrl;
    });
  },
)

// Banner
ImageFilePicker(
  uploadType: ImageUploadType.banner,
  userId: currentUserId,
  buttonText: 'Cambiar Banner',
  previewHeight: 150,
  onUploadComplete: (response) {
    setState(() {
      bannerUrl = response.fileUrl;
    });
  },
)

// Portada de álbum
ImageFilePicker(
  uploadType: ImageUploadType.cover,
  productId: albumId,
  showPreview: true,
  onUploadComplete: (response) {
    coverImageUrl = response.fileUrl;
  },
)
```

**Características del widget:**
- ✅ Selección desde cámara o galería (modal bottom sheet)
- ✅ Preview de la imagen seleccionada
- ✅ Optimización automática antes de subir (resize según tipo)
- ✅ Validación de formato y tamaño
- ✅ Tres tipos diferentes: profile, banner, cover
- ✅ Personalizable (altura de preview, texto del botón, etc.)

---

### Testing GA01-52F

**Test manual:**
1. Usar el widget en una pantalla de perfil
2. Tocar el botón → Debe mostrar opciones (cámara/galería)
3. Seleccionar de galería → Preview debe mostrarse
4. Debe subir correctamente y llamar `onUploadComplete`
5. Verificar que la URL retornada es válida

---

## GA01-55F: Reproducción de Audio con Streaming (Frontend)

### Objetivo
El `AudioProvider` existente con `just_audio` ya soporta streaming automáticamente cuando se usa `setUrl()` con URLs HTTP. El backend implementa Range Requests, por lo que no necesitamos cambios adicionales.

### Verificación

#### Verificar que `AudioProvider` usa `just_audio`

**Archivo:** `lib/core/providers/audio_provider.dart`

Buscar el método `playSong()`:

```dart
Future<void> playSong(Song song, {bool demo = false}) async {
  _demoFinished = false;
  try {
    _currentSong = song;
    _isDemoMode = demo;
    _queue = [song];
    _currentIndex = 0;

    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      // just_audio automáticamente usa Range Requests cuando es posible
      await _audioPlayer.setUrl(song.audioUrl!);
      await _audioPlayer.play();
    } else {
      debugPrint('No audio URL for song: ${song.name}');
    }

    notifyListeners();
  } catch (e) {
    debugPrint('Error playing song: $e');
  }
}
```

**¿Qué verifica este código?**
- ✅ `setUrl()` de just_audio automáticamente detecta si el servidor soporta Range Requests
- ✅ Si el servidor envía `Accept-Ranges: bytes`, just_audio hará peticiones con Range header
- ✅ Esto permite seek/scrub sin descargar todo el archivo
- ✅ No se requieren cambios en el código existente

### Uso Correcto

**Asegurarse de que las URLs de audio apunten al endpoint correcto:**

```dart
// ❌ INCORRECTO: URL directa a carpeta uploads
final song = Song(
  audioUrl: 'http://localhost:9001/uploads/audio-files/uuid.mp3',
);

// ✅ CORRECTO: URL al endpoint de FileServeController
final song = Song(
  audioUrl: 'http://localhost:9001/api/files/audio-files/uuid.mp3',
);
```

**El endpoint `/api/files/` es el que implementa Range Requests.**

### Testing GA01-55F

**Test con reproductor:**
1. Reproducir una canción con audioUrl apuntando a `/api/files/audio-files/...`
2. Intentar hacer seek al minuto 2:00
3. Verificar en Network Inspector que se envían headers `Range: bytes=...`
4. Verificar que el backend responde con `206 Partial Content`
5. El audio debe empezar desde el minuto 2:00 casi instantáneamente (sin descargar desde el inicio)

---

## GA01-56F: Compresión y Optimización de Imágenes (Frontend)

### Objetivo
Implementar funcionalidad para obtener estadísticas de compresión de imágenes (opcional, para mostrar al usuario).

### Archivos a Crear/Modificar

#### 1. MODIFICAR: `lib/core/api/services/file_upload_service.dart`

**Qué hacer:**
Agregar método para obtener estadísticas de compresión

```dart
/// Get image compression statistics
/// Returns optimization stats without actually saving the file
Future<ApiResponse<ImageCompressionStats>> getImageCompressionStats(
  File imageFile, {
  double quality = 0.8,
  int? maxWidth,
  int? maxHeight,
}) async {
  final fields = <String, String>{
    'quality': quality.toString(),
  };

  if (maxWidth != null) {
    fields['maxWidth'] = maxWidth.toString();
  }
  if (maxHeight != null) {
    fields['maxHeight'] = maxHeight.toString();
  }

  final response = await _apiClient.postMultipart(
    AppConstants.fileOptimizeImageUrl,
    file: imageFile,
    fileFieldName: 'file',
    fields: fields,
    requiresAuth: true,
  );

  if (response.success && response.data != null) {
    try {
      return ApiResponse(
        success: true,
        data: ImageCompressionStats.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Error al parsear estadísticas: $e',
      );
    }
  }
  return ApiResponse(success: false, error: response.error);
}
```

### Uso Opcional

**Mostrar estadísticas antes de subir:**

```dart
// En tu screen
Future<void> _showCompressionStats(File imageFile) async {
  final fileUploadService = FileUploadService();

  final response = await fileUploadService.getImageCompressionStats(
    imageFile,
    quality: 0.7,
    maxWidth: 800,
    maxHeight: 600,
  );

  if (response.success && response.data != null) {
    final stats = response.data!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Optimización de Imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tamaño original: ${stats.originalSizeFormatted}'),
            Text('Tamaño optimizado: ${stats.compressedSizeFormatted}'),
            Text('Reducción: ${stats.compressionRatio.toStringAsFixed(2)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

**NOTA:** El widget `ImageFilePicker` ya comprime automáticamente las imágenes ANTES de subir usando los parámetros de `ImagePicker`:

```dart
final pickedFile = await _imagePicker.pickImage(
  source: source,
  maxWidth: widget.uploadType == ImageUploadType.profile ? 1024 : 2048,
  maxHeight: widget.uploadType == ImageUploadType.profile ? 1024 : 2048,
  imageQuality: 85, // Calidad 85%
);
```

Por lo tanto, las imágenes ya están optimizadas en el cliente antes de enviarlas al servidor.

---

## Resumen de Implementación Completa

### Backend (Java Spring Boot)

| Componente | Archivo | Estado |
|------------|---------|--------|
| Validación de audio | FileStorageService.java | ⭐ MODIFICAR |
| Validación de imagen | FileStorageService.java | ✅ VERIFICAR |
| Upload audio | FileUploadController.java | ⭐ MODIFICAR |
| Upload imágenes | FileUploadController.java | ⭐ MODIFICAR |
| Streaming | FileServeController.java | ⭐ NUEVO |
| Compresión | ImageCompressionService.java | ⭐ NUEVO |
| Configuración | application.yml | ⭐ MODIFICAR |
| Dependencias | pom.xml | ⭐ MODIFICAR |

### Frontend (Flutter)

| Componente | Archivo | Estado |
|------------|---------|--------|
| Multipart upload | api_client.dart | ⭐ MODIFICAR |
| Modelos | file_upload_response.dart | ⭐ NUEVO |
| Constantes | constants.dart | ⭐ MODIFICAR |
| Servicio upload | file_upload_service.dart | ⭐ NUEVO |
| Widget audio | audio_file_picker.dart | ⭐ NUEVO |
| Widget imagen | image_file_picker.dart | ⭐ NUEVO |
| Reproductor | audio_provider.dart | ✅ YA EXISTE |

### Flujo Completo de Upload

```
1. Usuario selecciona archivo en Flutter
   ↓
2. Widget valida formato y tamaño
   ↓
3. FileUploadService.uploadAudioFile() / uploadProfileImage()
   ↓
4. ApiClient.postMultipart() envía petición multipart/form-data
   ↓
5. FileUploadController recibe y valida
   ↓
6. FileStorageService.storeFile() guarda en disco
   ↓
7. Backend retorna JSON con fileUrl y filePath
   ↓
8. Flutter recibe FileUploadResponse
   ↓
9. Widget llama onUploadComplete(response)
   ↓
10. App actualiza UI con la nueva URL
```

### Flujo de Streaming de Audio

```
1. Usuario toca play en canción
   ↓
2. AudioProvider.playSong(song)
   ↓
3. just_audio player: setUrl(song.audioUrl)
   ↓
4. just_audio detecta que el servidor soporta Range Requests
   ↓
5. Primera petición: Range: bytes=0-1048575 (primeros 1MB)
   ↓
6. FileServeController.handleRangeRequest()
   ↓
7. Respuesta: 206 Partial Content con primeros bytes
   ↓
8. Audio empieza a reproducirse
   ↓
9. Usuario hace seek al minuto 2:00
   ↓
10. just_audio calcula el byte offset
   ↓
11. Nueva petición: Range: bytes=3200000-...
   ↓
12. FileServeController retorna solo esos bytes
   ↓
13. Audio salta al minuto 2:00 instantáneamente
```

---

## Checklist de Verificación Final

### Backend
- [ ] FileStorageService tiene isValidAudioFile() y isValidImageFile()
- [ ] FileUploadController tiene endpoints de audio, profile, banner, cover
- [ ] FileServeController maneja Range Requests correctamente
- [ ] ImageCompressionService comprime imágenes JPEG con calidad ajustable
- [ ] application.yml tiene configuración de uploads (50MB)
- [ ] pom.xml tiene dependencia imgscalr-lib
- [ ] Directorio uploads/ se crea automáticamente
- [ ] Todos los endpoints retornan JSON con fileUrl y filePath

### Frontend
- [ ] ApiClient tiene método postMultipart()
- [ ] FileUploadResponse y ImageCompressionStats modelan las respuestas
- [ ] AppConstants tiene todos los endpoints de files
- [ ] FileUploadService tiene métodos para audio e imágenes
- [ ] AudioFilePicker widget funciona correctamente
- [ ] ImageFilePicker widget funciona correctamente
- [ ] AudioProvider usa just_audio con URLs correctas
- [ ] pubspec.yaml tiene file_picker, image_picker, http_parser

### Testing End-to-End
- [ ] Subir MP3 desde Flutter → Se guarda en backend → URL es accesible
- [ ] Subir imagen de perfil → Se guarda → Se muestra en UI
- [ ] Reproducir audio → Hacer seek → Funciona sin demora
- [ ] Seleccionar imagen desde cámara → Funciona
- [ ] Seleccionar imagen desde galería → Funciona
- [ ] Archivos > tamaño máximo son rechazados
- [ ] Formatos inválidos son rechazados
- [ ] URLs retornadas apuntan a /api/files/ (no a /uploads/ directamente)

---

**Última actualización:** 2025-11-05

**Versión:** 1.0
