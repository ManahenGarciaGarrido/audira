import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../../../data/services/album_service.dart';
import '../../../data/services/genre_service.dart';
import '../../../data/services/song_service.dart';
import '../../../data/services/auth_service.dart';

/// Pantalla completa para crear un nuevo álbum
class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _albumService = AlbumService();
  final _genreService = GenreService();
  final _songService = SongService();
  final _authService = AuthService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController(text: '15');

  // Estados
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  File? _coverImage;
  DateTime _releaseDate = DateTime.now();
  List<String> _selectedGenreIds = [];
  List<String> _selectedSongIds = [];

  // Data
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> _artistSongs = [];

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
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      // Cargar géneros
      final genres = await _genreService.getAllGenres();

      // Cargar canciones del artista
      final userId = await _authService.getUserId();
      final songs = userId != null
          ? await _songService.getSongsByArtist(userId)
          : <Map<String, dynamic>>[];

      setState(() {
        _genres = genres;
        _artistSongs = songs;
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
      if (!FilePickerHelper.validateFileSize(image, 5.0)) {
        _showErrorDialog('La imagen no debe superar 5MB');
        return;
      }
      setState(() => _coverImage = image);
    }
  }

  Future<void> _selectReleaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _releaseDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
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

      final album = await _albumService.createAlbum(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        artistId: userId,
        price: double.parse(_priceController.text.trim()),
        releaseDate: _releaseDate,
        genreIds: _selectedGenreIds,
        discountPercentage: double.parse(_discountController.text.trim()),
        coverImagePath: _coverImage?.path,
        onUploadProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      // Si hay canciones seleccionadas, actualizarlas para que pertenezcan al álbum
      if (_selectedSongIds.isNotEmpty) {
        for (final songId in _selectedSongIds) {
          try {
            await _songService.updateSong(
              songId: songId,
              albumId: album['id'],
            );
          } catch (e) {
            print('Error añadiendo canción $songId al álbum: $e');
          }
        }
      }

      setState(() => _isLoading = false);

      _showSuccessDialog('Álbum creado exitosamente');

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, album);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error creando álbum: $e');
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
        title: const Text('Crear Nuevo Álbum'),
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

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del álbum *',
                        hintText: 'Ej: Abbey Road',
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
                        hintText: 'Describe tu álbum...',
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

                    // Price and Discount Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio (USD) *',
                              hintText: '19.99',
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
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'Descuento (%)',
                              hintText: '15',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final discount = int.tryParse(value);
                                if (discount == null ||
                                    discount < 0 ||
                                    discount > 100) {
                                  return 'Entre 0-100';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Release Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha de lanzamiento *'),
                      subtitle: Text(
                        '${_releaseDate.day}/${_releaseDate.month}/${_releaseDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectReleaseDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Genres
                    _buildGenresSection(),
                    const SizedBox(height: 16),

                    // Songs (optional)
                    _buildSongsSection(),
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
                              'CREAR ÁLBUM',
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
          'Portada del álbum *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 250,
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
                        Icons.album,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seleccionar portada',
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

  Widget _buildSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Canciones del álbum (opcional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona canciones existentes para incluir en el álbum',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 12),
        if (_artistSongs.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No tienes canciones disponibles. Crea canciones primero.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          )
        else
          ...List.generate(
            _artistSongs.length > 5 ? 5 : _artistSongs.length,
            (index) {
              final song = _artistSongs[index];
              final isSelected = _selectedSongIds.contains(song['id']);
              return CheckboxListTile(
                title: Text(song['name'] ?? song['title'] ?? 'Sin nombre'),
                subtitle: Text(
                  'Duración: ${_formatDuration(song['duration'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedSongIds.add(song['id']);
                    } else {
                      _selectedSongIds.remove(song['id']);
                    }
                  });
                },
                secondary: Icon(
                  Icons.music_note,
                  color: AppTheme.primaryColor,
                ),
              );
            },
          ),
        if (_artistSongs.length > 5)
          TextButton(
            onPressed: () {
              // TODO: Mostrar diálogo con todas las canciones
            },
            child: const Text('Ver todas las canciones'),
          ),
      ],
    );
  }

  String _formatDuration(dynamic duration) {
    try {
      int seconds;
      if (duration is int) {
        seconds = duration;
      } else if (duration is Map && duration.containsKey('seconds')) {
        seconds = duration['seconds'] as int;
      } else {
        return '0:00';
      }

      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }
}
