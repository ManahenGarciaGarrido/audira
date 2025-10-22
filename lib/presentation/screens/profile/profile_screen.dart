import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state.status == AuthStatus.authenticated;

        if (!isAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Inicia sesión para ver tu perfil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 3),
          );
        }

        final user = state.user!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditProfileDialog(context, user);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Profile Image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),

                // Username
                if (user.username != null)
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 8),

                // Role Badge
                Chip(
                  label: Text(_getRoleLabel(user.role)),
                  avatar: Icon(_getRoleIcon(user.role), size: 18),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 32),

                // User Info
                _buildInfoSection(context, user),

                const SizedBox(height: 16),

                // Statistics
                if (user.role == UserRole.artist) _buildArtistStats(context),

                // Account Actions
                const SizedBox(height: 16),
                _buildAccountActions(context),

                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: user.role == UserRole.artist ? 4 : 3,
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow(context, Icons.email, 'Email', user.email),
            if (user.birthDate != null)
              _buildInfoRow(
                context,
                Icons.cake,
                'Fecha de nacimiento',
                '${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}',
              ),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Miembro desde',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistStats(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadísticas', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '12', 'Canciones'),
                _buildStatItem(context, '3', 'Álbumes'),
                _buildStatItem(context, '1.2K', 'Seguidores'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(color: AppColors.primary),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Cambiar contraseña'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notificaciones'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacidad'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: AppColors.error),
          ),
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return 'Invitado';
      case UserRole.member:
        return 'Miembro';
      case UserRole.artist:
        return 'Artista';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return Icons.person_outline;
      case UserRole.member:
        return Icons.person;
      case UserRole.artist:
        return Icons.music_note;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
          ],
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
                const SnackBar(content: Text('Perfil actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
