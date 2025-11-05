package io.audira.community.controller;

import io.audira.community.dto.UserDTO;
import io.audira.community.service.FileStorageService;
import io.audira.community.service.ImageCompressionService;
import io.audira.community.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileStorageService fileStorageService;
    private final UserService userService;
    private final ImageCompressionService imageCompressionService;

    @Value("${file.base-url:http://localhost:9001}")
    private String baseUrl;

    @PostMapping("/upload/profile-image")
    public ResponseEntity<?> uploadProfileImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        try {
            // Log para debugging
            System.out.println("Recibido archivo: " + file.getOriginalFilename());
            System.out.println("Content-Type: " + file.getContentType());
            System.out.println("Tamaño: " + file.getSize() + " bytes");

            // Validar que sea una imagen
            if (!fileStorageService.isValidImageFile(file)) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo debe ser una imagen (JPEG, PNG, GIF, WEBP)")
                );
            }

            // Validar tamaño (máximo 5MB)
            if (file.getSize() > 5 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo no debe superar los 5MB")
                );
            }

            // Guardar el archivo
            String filePath = fileStorageService.storeFile(file, "profile-images");
            String fileUrl = buildFileUrl(filePath);

            // Actualizar el usuario con la nueva URL
            Map<String, Object> updates = new HashMap<>();
            updates.put("profileImageUrl", fileUrl);
            UserDTO updatedUser = userService.updateProfile(userId, updates);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Imagen de perfil actualizada exitosamente");
            response.put("fileUrl", fileUrl);
            response.put("user", updatedUser);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                createErrorResponse("Error al subir la imagen: " + e.getMessage())
            );
        }
    }

    @PostMapping("/upload/banner-image")
    public ResponseEntity<?> uploadBannerImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        try {
            // Validar que sea una imagen
            if (!fileStorageService.isValidImageFile(file)) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo debe ser una imagen (JPEG, PNG, GIF, WEBP)")
                );
            }

            // Validar tamaño (máximo 10MB para banners)
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo no debe superar los 10MB")
                );
            }

            // Guardar el archivo
            String filePath = fileStorageService.storeFile(file, "banner-images");
            String fileUrl = buildFileUrl(filePath);

            // Actualizar el usuario con la nueva URL
            Map<String, Object> updates = new HashMap<>();
            updates.put("bannerImageUrl", fileUrl);
            UserDTO updatedUser = userService.updateProfile(userId, updates);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Imagen de banner actualizada exitosamente");
            response.put("fileUrl", fileUrl);
            response.put("user", updatedUser);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                createErrorResponse("Error al subir la imagen: " + e.getMessage())
            );
        }
    }

    @PostMapping("/upload/audio")
    public ResponseEntity<?> uploadAudioFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "songId", required = false) Long songId) {

        try {
            // Log para debugging
            System.out.println("Recibido archivo de audio: " + file.getOriginalFilename());
            System.out.println("Content-Type: " + file.getContentType());
            System.out.println("Tamaño: " + file.getSize() + " bytes");

            // Validar que sea un archivo de audio
            if (!fileStorageService.isValidAudioFile(file)) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo debe ser un archivo de audio válido (MP3, WAV, FLAC, MIDI, OGG, AAC)")
                );
            }

            // Validar tamaño (máximo 50MB para archivos de audio)
            if (file.getSize() > 50 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo no debe superar los 50MB")
                );
            }

            // Guardar el archivo
            String filePath = fileStorageService.storeFile(file, "audio-files");
            String fileUrl = buildFileUrl(filePath);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Archivo de audio subido exitosamente");
            response.put("fileUrl", fileUrl);
            response.put("filePath", filePath);

            if (songId != null) {
                response.put("songId", songId);
            }

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                createErrorResponse("Error al subir el archivo de audio: " + e.getMessage())
            );
        }
    }

    @PostMapping("/upload/cover-image")
    public ResponseEntity<?> uploadCoverImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "productId", required = false) Long productId) {

        try {
            // Validar que sea una imagen
            if (!fileStorageService.isValidImageFile(file)) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo debe ser una imagen (JPEG, PNG, GIF, WEBP)")
                );
            }

            // Validar tamaño (máximo 10MB para portadas)
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo no debe superar los 10MB")
                );
            }

            // Guardar el archivo
            String filePath = fileStorageService.storeFile(file, "cover-images");
            String fileUrl = buildFileUrl(filePath);

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Imagen de portada subida exitosamente");
            response.put("fileUrl", fileUrl);
            response.put("filePath", filePath);

            if (productId != null) {
                response.put("productId", productId);
            }

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                createErrorResponse("Error al subir la imagen de portada: " + e.getMessage())
            );
        }
    }

    @PostMapping("/compress/image")
    public ResponseEntity<?> compressImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "quality", defaultValue = "0.7") float quality,
            @RequestParam(value = "maxWidth", required = false) Integer maxWidth,
            @RequestParam(value = "maxHeight", required = false) Integer maxHeight) {

        try {
            // Validar que sea una imagen
            if (!fileStorageService.isValidImageFile(file)) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo debe ser una imagen (JPEG, PNG, GIF, WEBP)")
                );
            }

            // Validar calidad
            if (quality < 0.0f || quality > 1.0f) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("La calidad debe estar entre 0.0 y 1.0")
                );
            }

            // Procesar la imagen
            InputStream compressedImage;
            if (maxWidth != null && maxHeight != null) {
                compressedImage = imageCompressionService.compressAndResize(file, maxWidth, maxHeight, quality);
            } else if (maxWidth != null || maxHeight != null) {
                int width = maxWidth != null ? maxWidth : 1920;
                int height = maxHeight != null ? maxHeight : 1080;
                compressedImage = imageCompressionService.compressAndResize(file, width, height, quality);
            } else {
                compressedImage = imageCompressionService.compressImage(file, quality);
            }

            // Retornar la imagen comprimida directamente
            byte[] imageBytes = compressedImage.readAllBytes();

            String contentType = file.getContentType();
            if (contentType == null) {
                contentType = "image/jpeg";
            }

            return ResponseEntity.ok()
                    .header("Content-Type", contentType)
                    .header("Content-Disposition", "attachment; filename=\"compressed_" + file.getOriginalFilename() + "\"")
                    .body(imageBytes);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                createErrorResponse("Error al comprimir la imagen: " + e.getMessage())
            );
        }
    }

    @PostMapping("/optimize/image")
    public ResponseEntity<?> optimizeAndUploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("subDirectory") String subDirectory,
            @RequestParam(value = "quality", defaultValue = "0.8") float quality,
            @RequestParam(value = "maxWidth", defaultValue = "1920") int maxWidth,
            @RequestParam(value = "maxHeight", defaultValue = "1080") int maxHeight) {

        try {
            // Validar que sea una imagen
            if (!fileStorageService.isValidImageFile(file)) {
                return ResponseEntity.badRequest().body(
                    createErrorResponse("El archivo debe ser una imagen (JPEG, PNG, GIF, WEBP)")
                );
            }

            // Comprimir y redimensionar
            InputStream optimizedImage = imageCompressionService.compressAndResize(file, maxWidth, maxHeight, quality);

            // Crear un MultipartFile temporal con la imagen optimizada
            byte[] imageBytes = optimizedImage.readAllBytes();

            // Guardar la imagen optimizada
            // Nota: Para esto necesitaríamos crear un MultipartFile wrapper, por ahora retornamos la imagen
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Imagen optimizada exitosamente");
            response.put("originalSize", file.getSize());
            response.put("optimizedSize", imageBytes.length);
            response.put("compressionRatio", String.format("%.2f%%", (1 - (double)imageBytes.length / file.getSize()) * 100));

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                createErrorResponse("Error al optimizar la imagen: " + e.getMessage())
            );
        }
    }

    private Map<String, String> createErrorResponse(String message) {
        Map<String, String> error = new HashMap<>();
        error.put("error", message);
        return error;
    }

    private String buildFileUrl(String filePath) {
        return baseUrl + "/api/files/" + filePath;
    }
}
