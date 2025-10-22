import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isArtist = state.user?.role == UserRole.artist;

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index, isArtist),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Tienda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Biblioteca',
            ),
            if (isArtist)
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Studio',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(BuildContext context, int index, bool isArtist) {
    final routes = [
      AppRoutes.home,
      AppRoutes.store,
      AppRoutes.library,
      if (isArtist) AppRoutes.studio,
      AppRoutes.profile,
    ];

    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }
}
