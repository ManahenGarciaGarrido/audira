# Audira Multimedia File Management - Comprehensive Analysis

## Executive Summary

The Audira application has **partial implementation** of multimedia file management. Image uploads are implemented, but critical audio file handling is still incomplete. The application's architecture is ready for expansion but requires significant work on audio streaming and file processing.

---

## 1. Current Implementation Status

### 1.1 IMPLEMENTED: Image File Uploads

#### Backend (Java/Spring Boot)
**Location**: `/home/user/audira/community-service/`

**FileStorageService** (`src/main/java/io/audira/community/service/FileStorageService.java`)
- Upload location: Configured via `file.upload-dir` property (default: `uploads/`)
- File validation for images (JPEG, PNG, GIF, WEBP)
- Unique filename generation using UUID
- Subdirectory organization (profile-images, banner-images)
- File size limits enforced at controller level (5MB for profiles, 10MB for banners)
- Multipart file handling using Spring's MultipartFile

**FileUploadController** (`src/main/java/io/audira/community/controller/FileUploadController.java`)
- Endpoint: `POST /api/files/upload/profile-image`
- Endpoint: `POST /api/files/upload/banner-image`
- Parameters: file (MultipartFile), userId (Long)
- Returns: Updated user object with new image URL
- File validation before upload
- Size validation (5MB and 10MB limits)

**FileServeController** (`src/main/java/io/audira/community/controller/FileServeController.java`)
- Endpoint: `GET /api/files/{subDirectory}/{fileName}`
- Serves files as inline content
- Content-type detection based on file extension
- Proper resource handling and error responses

#### Frontend (Flutter)
**Auth Service** (`/lib/core/api/auth_service.dart`)
- Method: `uploadProfileImage(File imageFile, int userId)`
- Uses http.MultipartRequest for file upload
- Content-type detection (JPEG, PNG, GIF, WEBP)
- Automatic content-type assignment
- Response parsing and user data update

**Edit Profile Screen** (`/lib/features/profile/screens/edit_profile_screen.dart`)
- Image picker integration (image_picker package)
- Max dimensions: 1024x1024
- Quality compression: 85%
- Real-time upload feedback
- Progress indication

**Configuration** (`pubspec.yaml`)
- `image_picker: ^1.0.7` - Image selection
- `http: ^1.2.0` - HTTP requests
- `http_parser: ^4.0.2` - Multipart handling

---

### 1.2 PARTIALLY IMPLEMENTED: Audio File Model

#### Database Model
**Song Model** (`/home/user/audira/music-catalog-service/src/main/java/io/audira/catalog/model/Song.java`)
```java
@Column(name = "audio_url")
private String audioUrl;  // Stores audio file URL
private Integer duration;  // Duration in seconds
```

**Flutter Model** (`/lib/core/models/song.dart`)
- `audioUrl` field for streaming URL
- Duration field (in seconds)
- Full serialization/deserialization support

---

### 1.3 IMPLEMENTED: Audio Playback

#### Backend Playback Control
**PlaybackController** (`/home/user/audira/playback-service/src/main/java/io/audira/playback/controller/PlaybackController.java`)
- Endpoints: Play, Pause, Resume, Seek, Stop
- Playback sessions tracking
- History recording

#### Frontend Audio Player
**AudioProvider** (`/lib/core/providers/audio_provider.dart`)
- Uses `just_audio` package (v0.10.5)
- Full playback control (play, pause, next, previous, seek)
- Queue management
- Shuffle and repeat modes
- Progress tracking with listeners
- Demo mode (10-second preview)
- Stream support for live playback from URLs

**Configuration**
- `just_audio: ^0.10.5` - Audio playback
- `audio_session: ^0.2.2` - Session handling

---

### 1.4 PARTIALLY IMPLEMENTED: Upload UI Screens

**Upload Song Screen** (`/lib/features/studio/screens/upload_song_screen.dart`)
- File picker for audio (file_picker package v8.1.6)
- Image picker for cover art
- Form validation (song name, description, price, duration)
- Lyrics input field
- UI preview mode
- Upload progress indication
- **Issue**: Upload method `_uploadSong()` currently simulates upload only - no actual backend call

**Upload Album Screen** (`/lib/features/studio/screens/upload_album_screen.dart`)
- Cover image selection
- Album metadata (title, description, price, release date)
- Song selection from existing songs
- Upload progress UI
- **Issue**: `_uploadAlbum()` is UI-only, no backend integration

---

## 2. Missing/Incomplete Implementations

### 2.1 CRITICAL: Audio File Upload Endpoint

**Status**: NOT IMPLEMENTED

Required implementation:
```
POST /api/songs/upload - Accept multipart form with:
  - audio file (MP3, WAV, FLAC, OGG)
  - cover image
  - song metadata
  - artist ID
```

Current workaround: SongController only accepts JSON POST with audioUrl field
```java
@PostMapping
public ResponseEntity<Song> createSong(@RequestBody Song song)
// Does NOT handle file uploads
```

### 2.2 MISSING: Audio File Validation

Not implemented:
- Audio file format validation (MP3, WAV, FLAC, OGG, AAC)
- Audio metadata extraction (bitrate, sample rate, codec)
- Duration verification
- Audio content type validation
- File corruption detection

### 2.3 MISSING: Audio Streaming

Not implemented:
- Stream endpoint for audio files
- Range request support (for seeking in large files)
- Bandwidth optimization
- Content-type headers for audio/mpeg, audio/wav, etc.
- Cache control headers

### 2.4 MISSING: File Compression

Not implemented:
- Audio compression/transcoding
- Image optimization for album covers
- Quality reduction strategies
- Batch processing utilities

### 2.5 MISSING: Storage Configuration

**Current Setup**:
- Local file storage (filesystem-based)
- Configuration in `application.yml`:
  ```yaml
  file:
    upload-dir: uploads
    base-url: http://158.49.191.109:9001
  ```

Not implemented:
- AWS S3 integration
- Cloudinary integration
- MinIO support
- Azure Blob Storage
- Multi-cloud failover
- CDN integration

### 2.6 MISSING: Advanced File Management

Not implemented:
- File versioning
- Duplicate detection
- File integrity checking (checksums/hashes)
- Batch operations
- File expiration/cleanup
- Audit logging for file operations
- Encryption at rest
- DRM/License protection for audio files

### 2.7 MISSING: Chunked Uploads

Not implemented:
- Large file handling (>500MB)
- Resumable uploads
- Progress callback architecture
- Pause/resume functionality
- Network retry logic

---

## 3. Technical Stack

### Backend
- **Framework**: Spring Boot 2.x with Spring Cloud
- **Storage**: Local filesystem (Paths API)
- **Database**: PostgreSQL 15
- **Microservices**: 
  - community-service (9001) - File handling
  - music-catalog-service (9002) - Song metadata
  - playback-service (9003) - Playback control

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **Audio**: just_audio 0.10.5
- **File Selection**: 
  - image_picker: ^1.0.7
  - file_picker: ^8.1.6
- **HTTP**: http: ^1.2.0
- **State Management**: Provider 6.1.1

### Configuration
- **Max file size** (Spring): 10MB (both file and request)
- **Profile image limit**: 5MB
- **Banner image limit**: 10MB
- **Image quality**: 85% (Flutter compression)

---

## 4. Architecture Overview

### File Upload Flow (Current)

```
Frontend (Flutter)
    ↓
image_picker / file_picker
    ↓
Edit Profile Screen / Upload Screens
    ↓
http.MultipartRequest
    ↓
API Gateway (8080)
    ↓
Community Service (9001)
    ↓
FileUploadController
    ↓
FileStorageService
    ↓
Local Filesystem (./uploads/)
    ↓
FileServeController
    ↓
Browser/Client
```

### Missing Audio Upload Flow

```
[NEEDED]
Frontend
    ↓
Audio Picker + Image Picker
    ↓
MusicService / Artist Studio Screen
    ↓
http.MultipartRequest with audio + metadata
    ↓
API Gateway
    ↓
Music Catalog Service OR Community Service
    ↓
AudioUploadController (MISSING)
    ↓
AudioFileStorageService (MISSING)
    ↓
Cloud Storage or Filesystem
```

---

## 5. Database Schema

### Songs Table (`music-catalog-service`)
```sql
CREATE TABLE songs (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    artist_id BIGINT,
    album_id BIGINT,
    duration INTEGER,  -- in seconds
    audio_url VARCHAR(500),  -- URL to audio file
    cover_image_url VARCHAR(500),
    price DECIMAL(10,2),
    lyrics TEXT,
    track_number INTEGER,
    plays BIGINT DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### User Profile Images (`community-service`)
```sql
-- Users table (implied from FileUploadController usage)
ALTER TABLE users ADD COLUMN profile_image_url VARCHAR(500);
ALTER TABLE users ADD COLUMN banner_image_url VARCHAR(500);
```

---

## 6. Configuration Details

### Spring Boot Configuration
**File**: `/home/user/audira/community-service/src/main/resources/application.yml`

```yaml
server:
  port: 9001

spring:
  servlet:
    multipart:
      enabled: true
      max-file-size: 10MB
      max-request-size: 10MB

file:
  upload-dir: uploads  # Relative to working directory
  base-url: http://158.49.191.109:9001  # Server URL for file URLs
```

### Dependencies
- `spring-boot-starter-web` - REST endpoints
- `spring-boot-starter-validation` - File validation
- `spring-boot-starter-data-jpa` - Database persistence
- `postgresql` - Database driver
- `lombok` - Boilerplate reduction

---

## 7. API Endpoints Summary

### Implemented
```
GET    /api/files/{subDirectory}/{fileName}     - Serve file
POST   /api/files/upload/profile-image          - Upload profile image
POST   /api/files/upload/banner-image           - Upload banner image
```

### Not Implemented
```
POST   /api/songs/upload                        - Upload song with audio
POST   /api/albums/upload                       - Upload album
GET    /api/songs/{id}/stream                   - Stream audio file
POST   /api/files/validate                      - Validate file
DELETE /api/files/{subDirectory}/{fileName}     - Delete file
```

---

## 8. Security Considerations

### Currently Implemented
- JWT authentication on protected endpoints
- File type validation (extension and content-type)
- File size limits
- Path traversal prevention (normalize paths)
- HTTPS recommended (configured URL is HTTP)

### Missing
- Malware scanning
- DRM/License protection for audio
- Rate limiting for uploads
- Bandwidth throttling
- Access control lists (ACLs) for files
- Encryption for sensitive audio files
- Signature verification for downloads

---

## 9. Performance Issues

### Bottlenecks
1. **Single machine storage**: No redundancy or scalability
2. **HTTP storage serving**: No CDN acceleration
3. **No compression**: Bandwidth waste
4. **No caching**: Every file request hits disk
5. **No async uploads**: Blocks request thread
6. **No pagination**: Might load large metadata

### Recommended Improvements
- Implement async file processing with Spring Cloud Task
- Add Redis caching for file metadata
- Implement CDN (CloudFront, Cloudflare)
- Add compression pipelines
- Support ranged requests for partial downloads

---

## 10. Implementation Roadmap

### Phase 1: Audio Upload (High Priority)
- [ ] Create AudioUploadController
- [ ] Implement audio file validation
- [ ] Create MusicFileStorageService
- [ ] Update MusicService in Flutter
- [ ] Update UploadSongScreen with real upload
- [ ] Add error handling and retry logic

### Phase 2: Streaming & Optimization (High Priority)
- [ ] Implement audio streaming endpoint
- [ ] Add range request support
- [ ] Implement audio compression
- [ ] Add caching headers
- [ ] Optimize file serving

### Phase 3: Cloud Storage (Medium Priority)
- [ ] Implement S3 integration
- [ ] Implement Cloudinary support
- [ ] Add CDN configuration
- [ ] Implement multipart uploads
- [ ] Add resumable uploads

### Phase 4: Advanced Features (Low Priority)
- [ ] Audio metadata extraction
- [ ] Automatic transcoding
- [ ] License/DRM support
- [ ] Advanced analytics
- [ ] File versioning

---

## 11. Code Examples & Quick Reference

### Upload Image (Currently Working)
```dart
final response = await authService.uploadProfileImage(imageFile, userId);
```

### Upload Audio (Not Implemented)
```dart
// Needed implementation:
final response = await musicService.uploadSong(
  audioFile: File,
  coverImage: File,
  metadata: SongMetadata
);
```

### Play Audio (Currently Working)
```dart
await audioProvider.playSong(song, demo: false);
```

### Stream Audio (Not Implemented)
```
GET /api/songs/{id}/stream
Range: bytes=0-1000000
```

---

## 12. File Locations Reference

### Backend Files
| Component | Location |
|-----------|----------|
| File Upload Controller | `/home/user/audira/community-service/src/main/java/io/audira/community/controller/FileUploadController.java` |
| File Storage Service | `/home/user/audira/community-service/src/main/java/io/audira/community/service/FileStorageService.java` |
| File Serve Controller | `/home/user/audira/community-service/src/main/java/io/audira/community/controller/FileServeController.java` |
| Song Model | `/home/user/audira/music-catalog-service/src/main/java/io/audira/catalog/model/Song.java` |
| Song Controller | `/home/user/audira/music-catalog-service/src/main/java/io/audira/catalog/controller/SongController.java` |
| Configuration | `/home/user/audira/community-service/src/main/resources/application.yml` |

### Frontend Files
| Component | Location |
|-----------|----------|
| Audio Provider | `/home/user/audira/lib/core/providers/audio_provider.dart` |
| Auth Service | `/home/user/audira/lib/core/api/auth_service.dart` |
| Music Service | `/home/user/audira/lib/core/api/services/music_service.dart` |
| Song Model | `/home/user/audira/lib/core/models/song.dart` |
| Edit Profile Screen | `/home/user/audira/lib/features/profile/screens/edit_profile_screen.dart` |
| Upload Song Screen | `/home/user/audira/lib/features/studio/screens/upload_song_screen.dart` |
| Upload Album Screen | `/home/user/audira/lib/features/studio/screens/upload_album_screen.dart` |

---

## 13. Summary Matrix

| Feature | Status | Priority | Effort |
|---------|--------|----------|--------|
| Image Upload | ✅ Complete | - | - |
| Image Validation | ✅ Complete | - | - |
| Image Serving | ✅ Complete | - | - |
| Audio Upload | ❌ Missing | 🔴 High | 3 days |
| Audio Validation | ❌ Missing | 🔴 High | 2 days |
| Audio Streaming | ❌ Missing | 🔴 High | 2 days |
| Compression | ❌ Missing | 🟡 Medium | 3 days |
| Cloud Storage (S3) | ❌ Missing | 🟡 Medium | 4 days |
| CDN Integration | ❌ Missing | 🟢 Low | 2 days |
| DRM/License | ❌ Missing | 🟢 Low | 5 days |

---

## Conclusion

The Audira application has a **solid foundation for multimedia management** but is missing **critical audio file handling capabilities**. The architecture is microservices-based and scalable, but requires implementation of:

1. Audio file upload endpoints
2. Audio streaming capabilities
3. File compression utilities
4. Cloud storage configuration
5. Performance optimization

The image upload system can serve as a template for implementing audio uploads. Current priorities should be:
1. Complete audio upload pipeline
2. Implement streaming endpoints
3. Optimize file serving with caching
4. Add cloud storage support

