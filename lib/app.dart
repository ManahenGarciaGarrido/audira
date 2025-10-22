import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/studio/studio_screen.dart';
import 'presentation/screens/library/library_screen.dart';
import 'presentation/screens/cart/cart_screen.dart';
import 'presentation/screens/store/store_screen.dart';
import 'presentation/screens/details/song_detail_screen.dart';
import 'presentation/screens/details/album_detail_screen.dart';
import 'presentation/screens/info/contact_screen.dart';
import 'presentation/screens/info/faq_screen.dart';
// Nuevas importaciones
import 'presentation/screens/search/search_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.studio: (context) => const StudioScreen(),
        AppRoutes.library: (context) => const LibraryScreen(),
        AppRoutes.cart: (context) => const CartScreen(),
        AppRoutes.store: (context) => const StoreScreen(),
        AppRoutes.songDetail: (context) => const SongDetailScreen(),
        AppRoutes.albumDetail: (context) => const AlbumDetailScreen(),
        AppRoutes.contact: (context) => const ContactScreen(),
        AppRoutes.faq: (context) => const FaqScreen(),
        // Nueva ruta de búsqueda
        '/search': (context) => const SearchScreen(),
      },
    );
  }
}
