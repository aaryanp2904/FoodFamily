import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_provider.dart';
import 'screens/first_page.dart';
import 'screens/marketplace.dart';
import 'screens/sell_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create a ValueNotifier to manage the theme state
  final ValueNotifier<bool> _isDarkMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemProvider(),
      child: ValueListenableBuilder(
        valueListenable: _isDarkMode,
        builder: (context, isDark, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: isDark ? ThemeData.dark() : ThemeData.light(),
            home: FirstPage(isDarkMode: _isDarkMode),
            routes: {
              '/sell': (context) => SellPage(onSubmit: () {
                    // Navigate to the Marketplace screen
                    Navigator.of(context).pushReplacementNamed('/marketplace');
                  }),
              '/marketplace': (context) => Marketplace(),
              '/profile': (context) => ProfilePage(isDarkMode: _isDarkMode),
            },
          );
        },
      ),
    );
  }
}
