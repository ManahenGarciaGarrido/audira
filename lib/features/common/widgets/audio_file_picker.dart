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
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        if (widget.showProgress && _isUploading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppTheme.textGrey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue,
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
