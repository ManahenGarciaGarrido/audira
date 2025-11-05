package io.audira.community.controller;

import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor
public class FileServeController {

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    @GetMapping("/{subDirectory}/{fileName:.+}")
    public ResponseEntity<Resource> serveFile(
            @PathVariable String subDirectory,
            @PathVariable String fileName,
            @RequestHeader(value = "Range", required = false) String range) {

        try {
            Path fileStorageLocation = Paths.get(uploadDir).toAbsolutePath().normalize();
            Path filePath = fileStorageLocation.resolve(subDirectory).resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                String contentType = determineContentType(fileName);
                long fileLength = Files.size(filePath);

                // Si es un archivo de audio y se solicita un rango, manejar range request
                if (range != null && isAudioFile(fileName)) {
                    return handleRangeRequest(resource, filePath, range, contentType, fileLength);
                }

                // Respuesta normal para archivos sin rango o imágenes
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                        .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(fileLength))
                        .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            System.err.println("Error serving file: " + e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }

    private ResponseEntity<Resource> handleRangeRequest(Resource resource, Path filePath,
                                                         String range, String contentType,
                                                         long fileLength) throws IOException {
        // Parse range header (formato: "bytes=start-end")
        String[] ranges = range.replace("bytes=", "").split("-");
        long rangeStart = Long.parseLong(ranges[0]);
        long rangeEnd = ranges.length > 1 && !ranges[1].isEmpty()
            ? Long.parseLong(ranges[1])
            : fileLength - 1;

        if (rangeStart > rangeEnd || rangeEnd >= fileLength) {
            return ResponseEntity.status(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE)
                    .header(HttpHeaders.CONTENT_RANGE, "bytes */" + fileLength)
                    .build();
        }

        long contentLength = rangeEnd - rangeStart + 1;

        return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_RANGE, "bytes " + rangeStart + "-" + rangeEnd + "/" + fileLength)
                .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(contentLength))
                .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    private String determineContentType(String fileName) {
        String fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();

        // Tipos de imagen
        switch (fileExtension) {
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "png":
                return "image/png";
            case "gif":
                return "image/gif";
            case "webp":
                return "image/webp";

            // Tipos de audio
            case "mp3":
                return "audio/mpeg";
            case "wav":
                return "audio/wav";
            case "flac":
                return "audio/flac";
            case "ogg":
                return "audio/ogg";
            case "aac":
                return "audio/aac";
            case "midi":
            case "mid":
                return "audio/midi";

            default:
                return "application/octet-stream";
        }
    }

    private boolean isAudioFile(String fileName) {
        String fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
        return fileExtension.equals("mp3") ||
               fileExtension.equals("wav") ||
               fileExtension.equals("flac") ||
               fileExtension.equals("ogg") ||
               fileExtension.equals("aac") ||
               fileExtension.equals("midi") ||
               fileExtension.equals("mid");
    }
}
