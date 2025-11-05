package io.audira.community.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileStorageService {

    private final Path fileStorageLocation;
    private final S3StorageService s3StorageService;

    @Value("${aws.s3.enabled:false}")
    private boolean s3Enabled;

    @Autowired
    public FileStorageService(
            @Value("${file.upload-dir:uploads}") String uploadDir,
            S3StorageService s3StorageService) {
        this.fileStorageLocation = Paths.get(uploadDir).toAbsolutePath().normalize();
        this.s3StorageService = s3StorageService;
        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (Exception ex) {
            throw new RuntimeException("No se pudo crear el directorio de subida de archivos.", ex);
        }
    }

    public String storeFile(MultipartFile file, String subDirectory) {
        // Si S3 está habilitado, usar S3, sino usar almacenamiento local
        if (s3Enabled && s3StorageService.isS3Enabled()) {
            return s3StorageService.uploadFile(file, subDirectory);
        }

        return storeFileLocally(file, subDirectory);
    }

    private String storeFileLocally(MultipartFile file, String subDirectory) {
        // Normalizar nombre del archivo
        String originalFileName = StringUtils.cleanPath(file.getOriginalFilename());

        try {
            // Verificar que el archivo no esté vacío
            if (file.isEmpty()) {
                throw new RuntimeException("El archivo está vacío: " + originalFileName);
            }

            // Verificar que el nombre del archivo no contenga caracteres inválidos
            if (originalFileName.contains("..")) {
                throw new RuntimeException("El nombre del archivo contiene una secuencia de ruta inválida: " + originalFileName);
            }

            // Generar un nombre único para el archivo
            String fileExtension = "";
            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0) {
                fileExtension = originalFileName.substring(dotIndex);
            }
            String fileName = UUID.randomUUID().toString() + fileExtension;

            // Crear subdirectorio si es necesario
            Path targetLocation = this.fileStorageLocation.resolve(subDirectory);
            Files.createDirectories(targetLocation);

            // Copiar archivo a la ubicación de destino
            Path destinationFile = targetLocation.resolve(fileName);
            Files.copy(file.getInputStream(), destinationFile, StandardCopyOption.REPLACE_EXISTING);

            return subDirectory + "/" + fileName;
        } catch (IOException ex) {
            throw new RuntimeException("No se pudo almacenar el archivo " + originalFileName + ". Por favor, intente nuevamente.", ex);
        }
    }

    public void deleteFile(String filePath) {
        // Si S3 está habilitado y la ruta es una URL de S3, usar S3
        if (s3Enabled && s3StorageService.isS3Enabled() &&
            (filePath.startsWith("http://") || filePath.startsWith("https://"))) {
            s3StorageService.deleteFile(filePath);
            return;
        }

        // Sino, usar almacenamiento local
        try {
            Path file = this.fileStorageLocation.resolve(filePath).normalize();
            Files.deleteIfExists(file);
        } catch (IOException ex) {
            throw new RuntimeException("No se pudo eliminar el archivo: " + filePath, ex);
        }
    }

    public boolean isValidImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        String fileName = file.getOriginalFilename();

        // Verificar por content-type
        boolean validContentType = contentType != null && (
                contentType.equals("image/jpeg") ||
                contentType.equals("image/jpg") ||
                contentType.equals("image/png") ||
                contentType.equals("image/gif") ||
                contentType.equals("image/webp") ||
                contentType.equals("application/octet-stream") // Permitir este tipo genérico
        );

        // Verificar por extensión del archivo como fallback
        boolean validExtension = false;
        if (fileName != null) {
            String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
            validExtension = extension.equals("jpg") ||
                           extension.equals("jpeg") ||
                           extension.equals("png") ||
                           extension.equals("gif") ||
                           extension.equals("webp");
        }

        // Aceptar si el content-type O la extensión son válidos
        return validContentType || validExtension;
    }

    public boolean isValidAudioFile(MultipartFile file) {
        String contentType = file.getContentType();
        String fileName = file.getOriginalFilename();

        // Verificar por content-type
        boolean validContentType = contentType != null && (
                contentType.equals("audio/mpeg") ||
                contentType.equals("audio/mp3") ||
                contentType.equals("audio/wav") ||
                contentType.equals("audio/wave") ||
                contentType.equals("audio/x-wav") ||
                contentType.equals("audio/flac") ||
                contentType.equals("audio/x-flac") ||
                contentType.equals("audio/midi") ||
                contentType.equals("audio/x-midi") ||
                contentType.equals("audio/ogg") ||
                contentType.equals("audio/aac") ||
                contentType.equals("application/octet-stream") // Permitir este tipo genérico
        );

        // Verificar por extensión del archivo como fallback
        boolean validExtension = false;
        if (fileName != null) {
            String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
            validExtension = extension.equals("mp3") ||
                           extension.equals("wav") ||
                           extension.equals("flac") ||
                           extension.equals("midi") ||
                           extension.equals("mid") ||
                           extension.equals("ogg") ||
                           extension.equals("aac");
        }

        // Aceptar si el content-type O la extensión son válidos
        return validContentType || validExtension;
    }
}
