package io.audira.community.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class S3StorageService {

    private final AmazonS3 amazonS3Client;

    @Value("${aws.s3.bucket-name:}")
    private String bucketName;

    @Value("${aws.s3.enabled:false}")
    private boolean s3Enabled;

    @Value("${aws.s3.public-url:}")
    private String publicUrl;

    public boolean isS3Enabled() {
        return s3Enabled && amazonS3Client != null && !bucketName.isEmpty();
    }

    public String uploadFile(MultipartFile file, String subDirectory) {
        if (!isS3Enabled()) {
            throw new RuntimeException("S3 no está habilitado o configurado correctamente");
        }

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

            // Construir la clave S3 con subdirectorio
            String s3Key = subDirectory + "/" + fileName;

            // Obtener el content type
            String contentType = file.getContentType();
            if (contentType == null || contentType.isEmpty()) {
                contentType = "application/octet-stream";
            }

            // Configurar metadatos
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());
            metadata.setContentType(contentType);

            // Subir el archivo a S3
            try (InputStream inputStream = file.getInputStream()) {
                PutObjectRequest putObjectRequest = new PutObjectRequest(
                        bucketName,
                        s3Key,
                        inputStream,
                        metadata
                ).withCannedAcl(CannedAccessControlList.PublicRead);

                amazonS3Client.putObject(putObjectRequest);
            }

            // Retornar la URL del archivo
            if (publicUrl != null && !publicUrl.isEmpty()) {
                return publicUrl + "/" + s3Key;
            } else {
                return amazonS3Client.getUrl(bucketName, s3Key).toString();
            }

        } catch (IOException ex) {
            throw new RuntimeException("No se pudo almacenar el archivo " + originalFileName + " en S3. Por favor, intente nuevamente.", ex);
        }
    }

    public void deleteFile(String fileUrl) {
        if (!isS3Enabled()) {
            throw new RuntimeException("S3 no está habilitado o configurado correctamente");
        }

        try {
            // Extraer la clave S3 de la URL
            String s3Key = extractS3KeyFromUrl(fileUrl);

            if (s3Key != null && !s3Key.isEmpty()) {
                amazonS3Client.deleteObject(bucketName, s3Key);
            }
        } catch (Exception ex) {
            throw new RuntimeException("No se pudo eliminar el archivo de S3: " + fileUrl, ex);
        }
    }

    public InputStream downloadFile(String s3Key) {
        if (!isS3Enabled()) {
            throw new RuntimeException("S3 no está habilitado o configurado correctamente");
        }

        try {
            S3Object s3Object = amazonS3Client.getObject(bucketName, s3Key);
            return s3Object.getObjectContent();
        } catch (Exception ex) {
            throw new RuntimeException("No se pudo descargar el archivo de S3: " + s3Key, ex);
        }
    }

    private String extractS3KeyFromUrl(String fileUrl) {
        // Si es una URL de S3, extraer la clave
        if (fileUrl.contains(bucketName)) {
            int bucketIndex = fileUrl.indexOf(bucketName);
            String afterBucket = fileUrl.substring(bucketIndex + bucketName.length());

            // Remover el primer "/" si existe
            if (afterBucket.startsWith("/")) {
                afterBucket = afterBucket.substring(1);
            }

            return afterBucket;
        }

        // Si no es una URL completa, asumir que es una clave directa
        return fileUrl;
    }

    public String getFileUrl(String s3Key) {
        if (!isS3Enabled()) {
            throw new RuntimeException("S3 no está habilitado o configurado correctamente");
        }

        if (publicUrl != null && !publicUrl.isEmpty()) {
            return publicUrl + "/" + s3Key;
        } else {
            return amazonS3Client.getUrl(bucketName, s3Key).toString();
        }
    }
}
