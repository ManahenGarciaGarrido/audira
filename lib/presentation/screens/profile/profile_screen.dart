import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'user_stats_screen.dart';

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
          leading: const Icon(Icons.bar_chart),
          title: const Text('Mis Estadísticas'),
          subtitle: const Text('Ver tiempo de escucha y más'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserStatsScreen(),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Cambiar contraseña'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showChangePasswordDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notificaciones'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showNotificationsDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacidad'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showPrivacyDialog(context);
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
              if (nameController.text.isEmpty ||
                  usernameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor completa todos los campos')),
                );
                return;
              }

              // Note: En una app real, esto debería actualizar el usuario en el backend
              // y luego actualizar el state del AuthBloc
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureText1 = true;
    bool obscureText2 = true;
    bool obscureText3 = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText1 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureText1 = !obscureText1;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText1,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText2 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureText2 = !obscureText2;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText3 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureText3 = !obscureText3;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText3,
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
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor completa todos los campos')),
                  );
                  return;
                }

                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Las contraseñas no coinciden')),
                  );
                  return;
                }

                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('La contraseña debe tener al menos 6 caracteres')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña actualizada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    bool emailNotifications = true;
    bool pushNotifications = true;
    bool newReleasesNotifications = true;
    bool promotionsNotifications = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Notificaciones'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Notificaciones por email'),
                  subtitle:
                      const Text('Recibir actualizaciones por correo electrónico'),
                  value: emailNotifications,
                  onChanged: (value) {
                    setDialogState(() {
                      emailNotifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Notificaciones push'),
                  subtitle: const Text('Recibir notificaciones en el dispositivo'),
                  value: pushNotifications,
                  onChanged: (value) {
                    setDialogState(() {
                      pushNotifications = value;
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Nuevos lanzamientos'),
                  subtitle: const Text('Notificar sobre nueva música'),
                  value: newReleasesNotifications,
                  onChanged: (value) {
                    setDialogState(() {
                      newReleasesNotifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Promociones'),
                  subtitle: const Text('Ofertas y descuentos especiales'),
                  value: promotionsNotifications,
                  onChanged: (value) {
                    setDialogState(() {
                      promotionsNotifications = value;
                    });
                  },
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
                  const SnackBar(
                    content: Text('Preferencias de notificaciones guardadas'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    bool profilePublic = true;
    bool showPlaylistsToOthers = true;
    bool showPurchaseHistory = false;
    bool allowDataAnalytics = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Privacidad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración de privacidad',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Perfil público'),
                  subtitle: const Text('Permitir que otros vean tu perfil'),
                  value: profilePublic,
                  onChanged: (value) {
                    setDialogState(() {
                      profilePublic = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Mostrar playlists'),
                  subtitle: const Text('Compartir tus playlists públicamente'),
                  value: showPlaylistsToOthers,
                  onChanged: (value) {
                    setDialogState(() {
                      showPlaylistsToOthers = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Historial de compras'),
                  subtitle: const Text('Mostrar tus compras en tu perfil'),
                  value: showPurchaseHistory,
                  onChanged: (value) {
                    setDialogState(() {
                      showPurchaseHistory = value;
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Análisis de datos'),
                  subtitle: const Text('Ayudarnos a mejorar la app'),
                  value: allowDataAnalytics,
                  onChanged: (value) {
                    setDialogState(() {
                      allowDataAnalytics = value;
                    });
                  },
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
                  const SnackBar(
                    content: Text('Configuración de privacidad guardada'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
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
