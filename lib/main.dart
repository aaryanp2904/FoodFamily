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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/kitchen.dart';
import 'screens/list_new_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

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
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received message while in foreground: ${message.notification?.body}');
      // Handle the message and show a notification
      if (message.notification != null) {
        _showNotification(message.notification!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Handle the message
    });

    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        saveTokenToDatabase(token);
      }
    });
  }

  void saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'token': token,
      });
    }
  }

  void _showNotification(RemoteNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title ?? 'Notification'),
          content: Text(notification.body ?? 'You have a new message.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
              '/kitchen': (context) => Kitchen(onSubmit: () {
                Navigator.of(context)
                    .pushReplacementNamed('/marketplace');
              },isDarkMode: _isDarkMode),
              '/list_new_item': (context) => ListNewItemPage(onSubmit: () {}),
            },
          );
        },
      ),
    );
  }

  final ValueNotifier<bool> _isDarkMode = ValueNotifier(false);

  ThemeData get dark => ThemeData(
        textTheme: Typography.whiteCupertino,
        brightness: Brightness.dark,
        useMaterial3: true,
      );

  ThemeData get light => ThemeData(
        primaryColor: Colors.white,
        textTheme: Typography.blackCupertino,
        brightness: Brightness.light,
        useMaterial3: true,
      );
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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
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

Future<void> initializeUser() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'kitchenId': '', // Initialize with empty string or create a new kitchen
      });
    } else {
      // Ensure kitchenId exists in the document
      if (!userDoc.data()!.containsKey('kitchenId')) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'kitchenId': '', // Initialize with empty string or create a new kitchen
        });
      }
    }
  }
}
