import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';

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
            onPressed: () => _showUploadDialog(context),
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
                () => _showUploadDialog(context),
              ),
              _buildActionCard(
                context,
                'Crear Álbum',
                Icons.album,
                () => _showCreateAlbumDialog(context),
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

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Subir Canción'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Título')),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Precio (\$)'),
                keyboardType: TextInputType.number,
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
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            child: const Text('Subir'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de álbumes en desarrollo')),
    );
  }

  void _showStatsDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estadísticas detalladas en desarrollo')),
    );
  }

  void _showManageContentDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestión de contenido en desarrollo')),
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
