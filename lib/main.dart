// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_provider.dart';
import 'screens/first_page.dart';
import 'screens/marketplace.dart';
import 'screens/sell_page.dart';
import 'screens/profile_page.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAeqir9YNwIIRhmPBd78nSv-FjEcRc5_VA",
            authDomain: "drp-21.firebaseapp.com",
            projectId: "drp-21",
            storageBucket: "drp-21.appspot.com",
            messagingSenderId: "1001319224053",
            appId: "1:1001319224053:web:b2761e88aae5a36cc56bbc"));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create a ValueNotifier to manage the theme state
  final ValueNotifier<bool> _isDarkMode = ValueNotifier(false);

  ThemeData dark = ThemeData(
    textTheme: Typography.whiteCupertino,
    brightness: Brightness.dark,
    useMaterial3: true,
  );

  ThemeData light = ThemeData(
    primaryColor: Colors.white,
    textTheme: Typography.blackCupertino,
    brightness: Brightness.light,
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: ValueListenableBuilder(
        valueListenable: _isDarkMode,
        builder: (context, isDark, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: isDark ? dark : light,
            home: AuthWrapper(isDarkMode: _isDarkMode),
            routes: {
              '/login': (context) => LoginPage(),
              '/register': (context) => RegisterPage(),
              '/first_page': (context) => FirstPage(isDarkMode: _isDarkMode),
              '/sell': (context) => SellPage(
                    onSubmit: () {
                      Navigator.of(context)
                          .pushReplacementNamed('/marketplace');
                    },
                    isDarkMode: _isDarkMode,
                  ),
              '/marketplace': (context) => Marketplace(isDarkMode: _isDarkMode),
              '/profile': (context) => ProfilePage(isDarkMode: _isDarkMode),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final ValueNotifier<bool> isDarkMode;

  const AuthWrapper({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return FirstPage(
              isDarkMode:
                  isDarkMode); // Navigate to FirstPage if user is authenticated
        } else {
          return LoginPage(); // Navigate to LoginPage if user is not authenticated
        }
      },
    );
  }
}
