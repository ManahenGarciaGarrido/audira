# Gestión de Archivos Multimedia - Audira

Sistema de gestión de archivos multimedia con almacenamiento local para audio e imágenes.

## 📋 Características Implementadas

### ✅ GA01-51: Upload de Archivos de Audio
- Formatos soportados: MP3, WAV, FLAC, MIDI, OGG, AAC
- Límite de tamaño: 50MB por archivo
- Validación dual: content-type y extensión
- Almacenamiento en `uploads/audio-files/`

### ✅ GA01-52: Upload de Archivos de Imagen
- Formatos soportados: JPG, PNG, GIF, WEBP
- Límites de tamaño:
  - Imagen de perfil: 5MB
  - Imagen de banner: 10MB
  - Imagen de portada: 10MB
- Subdirectorios: `profile-images/`, `banner-images/`, `cover-images/`

### ✅ GA01-55: Streaming de Audio Eficiente
- Soporte completo para HTTP Range Requests
- Permite seek/scrubbing en reproductores de audio
- Content-Type correcto según formato
- Headers optimizados para streaming

### ✅ GA01-56: Compresión de Imágenes
- Compresión con control de calidad (0.0 - 1.0)
- Redimensionamiento manteniendo proporciones
- Estadísticas de compresión

---

## 🛠️ Endpoints de API

### 1. Upload de Audio
```http
POST /api/files/upload/audio
Content-Type: multipart/form-data

Parámetros:
  - file (required): Archivo de audio
  - songId (optional): ID de la canción asociada

Respuesta:
{
  "message": "Archivo de audio subido exitosamente",
  "fileUrl": "http://localhost:9001/api/files/audio-files/uuid.mp3",
  "filePath": "audio-files/uuid.mp3",
  "songId": 123
}
```

### 2. Servir Archivos (con Range Requests)
```http
GET /api/files/{subDirectory}/{fileName}

Headers opcionales:
  - Range: bytes=0-1023

Respuestas:
  - 200 OK: Archivo completo
  - 206 Partial Content: Rango del archivo
  - 404 Not Found: Archivo no encontrado
```

### 3. Comprimir Imagen
```http
POST /api/files/compress/image
Content-Type: multipart/form-data

Parámetros:
  - file (required): Archivo de imagen
  - quality (optional): 0.0-1.0 (default: 0.7)
  - maxWidth (optional): Ancho máximo
  - maxHeight (optional): Alto máximo

Respuesta:
  Archivo de imagen comprimida (binary)
```

---

## ⚙️ Configuración

### application.yml
```yaml
file:
  upload-dir: uploads
  base-url: http://localhost:9001

spring.servlet.multipart:
  enabled: true
  max-file-size: 50MB
  max-request-size: 50MB
```

### Estructura de Carpetas
```
community-service/
└── uploads/              ← Creado automáticamente
    ├── profile-images/
    ├── banner-images/
    ├── cover-images/
    └── audio-files/
```

---

## 📊 Formatos Soportados

### Audio
MP3, WAV, FLAC, MIDI, OGG, AAC

### Imagen
JPG, PNG, GIF, WEBP

---

## 🧪 Ejemplos de Uso

### Upload de Audio
```bash
curl -X POST http://localhost:9001/api/files/upload/audio \
  -F "file=@song.mp3" \
  -F "songId=1"
```

### Comprimir Imagen
```bash
curl -X POST http://localhost:9001/api/files/compress/image \
  -F "file=@photo.jpg" \
  -F "quality=0.8" \
  --output compressed.jpg
```

### Range Request
```bash
curl -H "Range: bytes=0-1023" \
  http://localhost:9001/api/files/audio-files/uuid.mp3
```

---

## 🚀 Compilar y Ejecutar

```bash
cd community-service
mvn clean package
java -jar target/community-service-1.0.0.jar
```

---

**Última actualización:** 2025-11-05
**Versión:** 1.0.0 (Almacenamiento local)
