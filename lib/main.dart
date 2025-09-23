import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rdg7/ui/user/user_list_screen.dart';
import 'package:rdg7/bloc/user_bloc.dart'; 

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<UserBloc>(
      create: (_) => UserBloc(),
      child: MaterialApp(
        title: 'RDG7 App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const UserListScreen(),
      ),
    );
  }
}
