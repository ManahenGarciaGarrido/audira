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
     * Comprime una imagen reduciendo su calidad
     * @param file El archivo de imagen original
     * @param quality Calidad de compresión (0.0 - 1.0, donde 1.0 es mejor calidad)
     * @return InputStream con la imagen comprimida
     */
    public InputStream compressImage(MultipartFile file, float quality) throws IOException {
        // Validar calidad
        if (quality < 0.0f || quality > 1.0f) {
            throw new IllegalArgumentException("La calidad debe estar entre 0.0 y 1.0");
        }

        // Leer la imagen
        BufferedImage image = ImageIO.read(file.getInputStream());
        if (image == null) {
            throw new IOException("No se pudo leer la imagen");
        }

        // Comprimir la imagen
        ByteArrayOutputStream compressed = new ByteArrayOutputStream();

        // Determinar el formato
        String originalFileName = file.getOriginalFilename();
        String formatName = "jpg"; // Por defecto JPEG

        if (originalFileName != null) {
            String extension = originalFileName.substring(originalFileName.lastIndexOf('.') + 1).toLowerCase();
            if (extension.equals("png")) {
                formatName = "png";
            } else if (extension.equals("webp")) {
                formatName = "webp";
            }
        }

        // Para JPEG, usar compresión con calidad
        if (formatName.equals("jpg") || formatName.equals("jpeg")) {
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpg");
            if (!writers.hasNext()) {
                throw new IOException("No hay escritores disponibles para JPEG");
            }

            ImageWriter writer = writers.next();
            ImageWriteParam param = writer.getDefaultWriteParam();

            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(quality);
            }

            try (ImageOutputStream ios = ImageIO.createImageOutputStream(compressed)) {
                writer.setOutput(ios);
                writer.write(null, new IIOImage(image, null, null), param);
                writer.dispose();
            }
        } else {
            // Para PNG y otros formatos, solo escribir sin compresión especial
            ImageIO.write(image, formatName, compressed);
        }

        return new ByteArrayInputStream(compressed.toByteArray());
    }

    /**
     * Redimensiona una imagen manteniendo la proporción
     * @param file El archivo de imagen original
     * @param maxWidth Ancho máximo
     * @param maxHeight Alto máximo
     * @return InputStream con la imagen redimensionada
     */
    public InputStream resizeImage(MultipartFile file, int maxWidth, int maxHeight) throws IOException {
        // Leer la imagen
        BufferedImage image = ImageIO.read(file.getInputStream());
        if (image == null) {
            throw new IOException("No se pudo leer la imagen");
        }

        // Redimensionar manteniendo la proporción
        BufferedImage resized = Scalr.resize(image,
                Scalr.Method.QUALITY,
                Scalr.Mode.FIT_TO_WIDTH,
                maxWidth,
                maxHeight,
                Scalr.OP_ANTIALIAS);

        // Convertir a InputStream
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        String formatName = getFormatName(file.getOriginalFilename());
        ImageIO.write(resized, formatName, output);

        return new ByteArrayInputStream(output.toByteArray());
    }

    /**
     * Comprime y redimensiona una imagen
     * @param file El archivo de imagen original
     * @param maxWidth Ancho máximo
     * @param maxHeight Alto máximo
     * @param quality Calidad de compresión (0.0 - 1.0)
     * @return InputStream con la imagen procesada
     */
    public InputStream compressAndResize(MultipartFile file, int maxWidth, int maxHeight, float quality) throws IOException {
        // Leer la imagen
        BufferedImage image = ImageIO.read(file.getInputStream());
        if (image == null) {
            throw new IOException("No se pudo leer la imagen");
        }

        // Redimensionar si es necesario
        if (image.getWidth() > maxWidth || image.getHeight() > maxHeight) {
            image = Scalr.resize(image,
                    Scalr.Method.QUALITY,
                    Scalr.Mode.FIT_TO_WIDTH,
                    maxWidth,
                    maxHeight,
                    Scalr.OP_ANTIALIAS);
        }

        // Comprimir
        ByteArrayOutputStream compressed = new ByteArrayOutputStream();
        String formatName = getFormatName(file.getOriginalFilename());

        if (formatName.equals("jpg") || formatName.equals("jpeg")) {
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpg");
            if (!writers.hasNext()) {
                throw new IOException("No hay escritores disponibles para JPEG");
            }

            ImageWriter writer = writers.next();
            ImageWriteParam param = writer.getDefaultWriteParam();

            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(quality);
            }

            try (ImageOutputStream ios = ImageIO.createImageOutputStream(compressed)) {
                writer.setOutput(ios);
                writer.write(null, new IIOImage(image, null, null), param);
                writer.dispose();
            }
        } else {
            ImageIO.write(image, formatName, compressed);
        }

        return new ByteArrayInputStream(compressed.toByteArray());
    }

    private String getFormatName(String fileName) {
        if (fileName == null) {
            return "jpg";
        }

        String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();

        switch (extension) {
            case "png":
                return "png";
            case "gif":
                return "gif";
            case "webp":
                return "webp";
            default:
                return "jpg";
        }
    }
}
