import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../../../data/services/song_service.dart';
import '../../../data/services/genre_service.dart';
import '../../../data/services/album_service.dart';
import '../../../data/services/auth_service.dart';

/// Pantalla completa para crear una nueva canción
/// Incluye upload de archivos, validaciones y preview
class CreateSongScreen extends StatefulWidget {
  const CreateSongScreen({super.key});

  @override
  State<CreateSongScreen> createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _songService = SongService();
  final _genreService = GenreService();
  final _albumService = AlbumService();
  final _authService = AuthService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _durationController = TextEditingController(); // en formato mm:ss

  // Estados
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  File? _coverImage;
  File? _audioFile;
  String? _selectedAlbumId;
  List<String> _selectedGenreIds = [];

  // Data
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> _albums = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _lyricsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      // Cargar géneros
      final genres = await _genreService.getAllGenres();

      // Cargar álbumes del artista
      final userId = await _authService.getUserId();
      final albums = userId != null
          ? await _albumService.getAlbumsByArtist(userId)
          : <Map<String, dynamic>>[];

      setState(() {
        _genres = genres;
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error cargando datos: $e');
    }
  }

  Future<void> _pickCoverImage() async {
    final image = await FilePickerHelper.pickImageFromGallery();
    if (image != null) {
      // Validar tamaño (máx 5MB)
      if (!FilePickerHelper.validateFileSize(image, 5.0)) {
        _showErrorDialog('La imagen no debe superar 5MB');
        return;
      }

      setState(() => _coverImage = image);
    }
  }

  Future<void> _pickAudioFile() async {
    final audio = await FilePickerHelper.pickAudioFile();
    if (audio != null) {
      // Validar tamaño (máx 50MB)
      if (!FilePickerHelper.validateFileSize(audio, 50.0)) {
        _showErrorDialog('El archivo de audio no debe superar 50MB');
        return;
      }

      setState(() => _audioFile = audio);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_audioFile == null) {
      _showErrorDialog('Debes seleccionar un archivo de audio');
      return;
    }

    if (_selectedGenreIds.isEmpty) {
      _showErrorDialog('Debes seleccionar al menos un género');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _uploadProgress = 0.0;
      });

      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Convertir duración de mm:ss a segundos
      final duration = _parseDuration(_durationController.text);

      final song = await _songService.createSong(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        artistId: userId,
        price: double.parse(_priceController.text.trim()),
        duration: duration,
        lyrics: _lyricsController.text.trim().isNotEmpty
            ? _lyricsController.text.trim()
            : null,
        albumId: _selectedAlbumId,
        genreIds: _selectedGenreIds,
        audioFilePath: _audioFile!.path,
        coverImagePath: _coverImage?.path,
        onUploadProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      setState(() => _isLoading = false);

      // Mostrar éxito
      _showSuccessDialog('Canción creada exitosamente');

      // Volver atrás después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, song);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error creando canción: $e');
    }
  }

  int _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length != 2) {
        throw const FormatException('Formato inválido');
      }
      final minutes = int.parse(parts[0]);
      final seconds = int.parse(parts[1]);
      return (minutes * 60) + seconds;
    } catch (e) {
      throw Exception('Formato de duración inválido. Usa mm:ss');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Canción'),
        elevation: 0,
      ),
      body: _isLoading && _genres.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cover Image
                    _buildCoverImageSection(),
                    const SizedBox(height: 24),

                    // Audio File
                    _buildAudioFileSection(),
                    const SizedBox(height: 24),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la canción *',
                        hintText: 'Ej: Bohemian Rhapsody',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        hintText: 'Describe tu canción...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price and Duration Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio (USD) *',
                              hintText: '9.99',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El precio es requerido';
                              }
                              final price = double.tryParse(value.trim());
                              if (price == null || price < 0) {
                                return 'Precio inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Duración *',
                              hintText: '03:45',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,2}:?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Duración requerida';
                              }
                              if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(value)) {
                                return 'Formato: mm:ss';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Genres
                    _buildGenresSection(),
                    const SizedBox(height: 16),

                    // Album (optional)
                    _buildAlbumSection(),
                    const SizedBox(height: 16),

                    // Lyrics (optional)
                    TextFormField(
                      controller: _lyricsController,
                      decoration: const InputDecoration(
                        labelText: 'Letra (opcional)',
                        hintText: 'Escribe la letra de la canción...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                    ),
                    const SizedBox(height: 24),

                    // Upload Progress
                    if (_isLoading && _uploadProgress > 0)
                      Column(
                        children: [
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: 8),
                          Text(
                            'Subiendo... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'CREAR CANCIÓN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen de portada *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: _coverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _coverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seleccionar imagen',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Máx 5MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archivo de audio *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickAudioFile,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: _audioFile != null
                ? Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FilePickerHelper.getFileInfo(_audioFile!)['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${FilePickerHelper.getFileInfo(_audioFile!)['sizeInMB']} MB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _audioFile = null),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.audio_file,
                        size: 32,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar archivo de audio',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'MP3, WAV, FLAC - Máx 50MB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Géneros *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres.map((genre) {
            final isSelected = _selectedGenreIds.contains(genre['id']);
            return FilterChip(
              label: Text(genre['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenreIds.add(genre['id']);
                  } else {
                    _selectedGenreIds.remove(genre['id']);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAlbumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Álbum (opcional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAlbumId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Selecciona un álbum',
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Sin álbum (Single)'),
            ),
            ..._albums.map((album) {
              return DropdownMenuItem(
                value: album['id'],
                child: Text(album['name'] ?? album['title'] ?? 'Sin nombre'),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedAlbumId = value);
          },
        ),
      ],
    );
  }
}
