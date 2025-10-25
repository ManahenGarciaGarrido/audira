import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/song_model.dart';
import '../../../data/models/album_model.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'create_song_screen.dart';
import 'create_album_screen.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.user?.role != UserRole.artist) {
          return Scaffold(
            appBar: AppBar(title: const Text('Studio')),
            body: const Center(child: Text('Acceso solo para artistas')),
            bottomNavigationBar: const BottomNavBar(currentIndex: 3),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Studio'),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  _showHelpDialog(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Stats
                _buildDashboardStats(context),

                const SizedBox(height: 16),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: 16),

                // Recent Activity
                _buildRecentActivity(context),

                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(currentIndex: 3),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToCreateSong(context),
            icon: const Icon(Icons.add),
            label: const Text('Subir Música'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildDashboardStats(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  context,
                  '15.2K',
                  'Reproducciones',
                  Icons.play_circle,
                ),
                _buildStatCard(
                  context,
                  '\$324',
                  'Ganancias',
                  Icons.attach_money,
                ),
                _buildStatCard(context, '12', 'Canciones', Icons.music_note),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2,
            children: [
              _buildActionCard(
                context,
                'Subir Canción',
                Icons.upload_file,
                () => _navigateToCreateSong(context),
              ),
              _buildActionCard(
                context,
                'Crear Álbum',
                Icons.album,
                () => _navigateToCreateAlbum(context),
              ),
              _buildActionCard(
                context,
                'Ver Estadísticas',
                Icons.bar_chart,
                () => _showStatsDialog(context),
              ),
              _buildActionCard(
                context,
                'Gestionar Contenido',
                Icons.library_music,
                () => _showManageContentDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.music_note,
                    color: AppColors.primary,
                  ),
                  title: Text('Midnight Dreams'),
                  subtitle: Text('125 reproducciones hoy'),
                  trailing: Icon(Icons.trending_up, color: Colors.green),
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.person_add,
                    color: AppColors.secondary,
                  ),
                  title: Text('15 nuevos seguidores'),
                  subtitle: Text('En los últimos 7 días'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text('Nueva valoración'),
                  subtitle: Text('5 estrellas en "Midnight Dreams"'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateSong(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateSongScreen(),
      ),
    ).then((result) {
      if (result != null) {
        // Canción creada exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Canción creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _navigateToCreateAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAlbumScreen(),
      ),
    ).then((result) {
      if (result != null) {
        // Álbum creado exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Álbum creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Mantener el viejo método para referencia pero renombrado
  void _showUploadDialog_OLD(BuildContext context) {
    final titleController = TextEditingController();
    final priceController = TextEditingController(text: '1.99');
    final repository = MockDataRepository();
    final user = context.read<AuthBloc>().state.user;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Subir Canción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Nombre de tu canción',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio (\$)',
                  hintText: '1.99',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nota: El archivo de audio se subiría aquí en producción',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un título')),
                );
                return;
              }

              final newSong = SongModel(
                id: 'song_${DateTime.now().millisecondsSinceEpoch}',
                title: titleController.text,
                artistId: user?.id ?? 'artist1',
                artistName: user?.name ?? 'Usuario',
                genres: const ['1'],
                duration: const Duration(minutes: 3, seconds: 30),
                releaseDate: DateTime.now(),
                price: double.tryParse(priceController.text) ?? 1.99,
                audioUrl: 'https://example.com/audio/uploaded.mp3',
                coverUrl:
                    'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=800&h=800&fit=crop',
                rating: 0.0,
                playCount: 0,
              );

              repository.addSong(newSong);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡"${newSong.title}" subida exitosamente!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Subir'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    final titleController = TextEditingController();
    final priceController = TextEditingController(text: '9.99');
    final repository = MockDataRepository();
    final user = context.read<AuthBloc>().state.user;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear Álbum'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Álbum',
                  hintText: 'Mi Nuevo Álbum',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio (\$)',
                  hintText: '9.99',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nota: Podrás agregar canciones después de crear el álbum',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor ingresa un título')),
                );
                return;
              }

              final newAlbum = AlbumModel(
                id: 'album_${DateTime.now().millisecondsSinceEpoch}',
                title: titleController.text,
                artistIds: [user?.id ?? 'artist1'],
                artistNames: [user?.name ?? 'Usuario'],
                songIds: const [],
                genres: const ['1'],
                totalDuration: const Duration(minutes: 0),
                year: DateTime.now().year,
                price: double.tryParse(priceController.text) ?? 9.99,
                coverUrl:
                    'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=800&h=800&fit=crop',
                rating: 0.0,
                salesCount: 0,
              );

              repository.addAlbum(newAlbum);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡Álbum "${newAlbum.title}" creado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    final repository = MockDataRepository();
    final user = context.read<AuthBloc>().state.user;
    final mySongs = repository.getSongsByArtist(user?.id ?? 'artist1');
    final myAlbums = repository.getAlbumsByArtist(user?.id ?? 'artist1');

    final totalPlays = mySongs.fold(0, (sum, song) => sum + song.playCount);
    final totalRevenue =
        mySongs.fold(0.0, (sum, song) => sum + (song.price * song.playCount));
    final avgRating = mySongs.isEmpty
        ? 0.0
        : mySongs.fold(0.0, (sum, song) => sum + song.rating) / mySongs.length;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Estadísticas Detalladas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.music_note, color: AppColors.primary),
                title: Text('${mySongs.length} Canciones'),
                subtitle: const Text('Total publicadas'),
              ),
              ListTile(
                leading: const Icon(Icons.album, color: AppColors.secondary),
                title: Text('${myAlbums.length} Álbumes'),
                subtitle: const Text('Total creados'),
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.play_circle, color: Colors.green),
                title: Text('$totalPlays Reproducciones'),
                subtitle: const Text('Total acumulado'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.attach_money, color: Colors.amber),
                title: Text('\$${totalRevenue.toStringAsFixed(2)}'),
                subtitle: const Text('Ingresos estimados'),
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: Text('${avgRating.toStringAsFixed(1)} / 5.0'),
                subtitle: const Text('Calificación promedio'),
              ),
              const Divider(),
              const Text(
                'Top Canciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...mySongs.take(3).map(
                    (song) => ListTile(
                      dense: true,
                      title: Text(song.title),
                      trailing: Text('${song.playCount} plays'),
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showManageContentDialog(BuildContext context) {
    final repository = MockDataRepository();
    final user = context.read<AuthBloc>().state.user;
    final mySongs = repository.getSongsByArtist(user?.id ?? 'artist1');
    final myAlbums = repository.getAlbumsByArtist(user?.id ?? 'artist1');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gestionar Contenido'),
        content: SizedBox(
          width: double.maxFinite,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Canciones'),
                    Tab(text: 'Álbumes'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      // Songs Tab
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: mySongs.length,
                        itemBuilder: (context, index) {
                          final song = mySongs[index];
                          return ListTile(
                            title: Text(song.title),
                            subtitle: Text(
                                '${song.playCount} plays • \$${song.price}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                repository.removeSong(song.id);
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '"${song.title}" eliminada'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      // Albums Tab
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: myAlbums.length,
                        itemBuilder: (context, index) {
                          final album = myAlbums[index];
                          return ListTile(
                            title: Text(album.title),
                            subtitle: Text(
                                '${album.songIds.length} canciones • \$${album.price}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                repository.removeAlbum(album.id);
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Álbum "${album.title}" eliminado'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ayuda de Studio'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo subir música?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '1. Presiona el botón "Subir Música"\n2. Completa la información\n3. Selecciona el archivo de audio',
              ),
              SizedBox(height: 16),
              Text(
                'Formatos soportados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('MP3, WAV, FLAC, MIDI'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
