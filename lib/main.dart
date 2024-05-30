import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_provider.dart';
import 'screens/first_page.dart';
import 'screens/marketplace.dart';
import 'screens/sell_page.dart';
import 'screens/profile_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyAeqir9YNwIIRhmPBd78nSv-FjEcRc5_VA",
    authDomain: "drp-21.firebaseapp.com",
    projectId: "drp-21",
    storageBucket: "drp-21.appspot.com",
    messagingSenderId: "1001319224053",
    appId: "1:1001319224053:web:b2761e88aae5a36cc56bbc"));
  }else{
    await Firebase.initializeApp();
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create a ValueNotifier to manage the theme state
  final ValueNotifier<bool> _isDarkMode = ValueNotifier(false);

  ThemeData dark = ThemeData(
      textTheme: Typography.whiteCupertino,
      brightness: Brightness.dark,
      useMaterial3: true);

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
            home: FirstPage(isDarkMode: _isDarkMode),
            routes: {
              '/sell': (context) => SellPage(onSubmit: () {
                    // Navigate to the Marketplace screen
                    Navigator.of(context).pushReplacementNamed('/marketplace');
                  }),
              '/marketplace': (context) => const Marketplace(),
              '/profile': (context) => ProfilePage(isDarkMode: _isDarkMode),
            },
          );
        },
      ),
    );
  }
}
