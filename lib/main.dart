import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:rdg7/ui/home/home_screen.dart';
import 'package:rdg7/bloc/user_bloc.dart';
import 'package:rdg7/bloc/reservation_bloc.dart';
import 'package:rdg7/bloc/court_bloc.dart';
import 'package:rdg7/bloc/sport_bloc.dart';
import 'package:rdg7/bloc/support_bloc.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<UserBloc>(
            create: (_) => UserBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<ReservationBloc>(
            create: (_) => ReservationBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<CourtBloc>(
            create: (_) => CourtBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<SportBloc>(
            create: (_) => SportBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          
          ChangeNotifierProvider<SupportBloc>(
            create: (_) => SupportBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'RDG7 App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF2B6CB0),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2B6CB0)),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2B6CB0),
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF2B6CB0)),
                foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
              ),
            ),
          ),
          home: const HomeScreen(),
        ),
      );
}
