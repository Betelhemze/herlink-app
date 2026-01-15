import 'package:flutter/material.dart';
import 'package:herlink/home.dart';
import 'package:herlink/login.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: AuthStorage.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final bool isLoggedIn = snapshot.hasData && snapshot.data != null;
          return isLoggedIn ? const HomePage() : const SplashScreen();
        },
      ),
    );
  }
}
