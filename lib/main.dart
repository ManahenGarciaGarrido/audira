import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/player/player_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/library/library_bloc.dart';
import 'data/repositories/mock_data_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AudiraApp());
}

class AudiraApp extends StatelessWidget {
  const AudiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MockDataRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(repository)..add(const AuthCheckStatus()),
        ),
        BlocProvider<PlayerBloc>(
          create: (context) => PlayerBloc(),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(),
        ),
        BlocProvider<LibraryBloc>(
          create: (context) => LibraryBloc(repository),
        ),
      ],
      child: const App(),
    );
  }
}
