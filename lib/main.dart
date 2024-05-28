import 'package:flutter/material.dart';
import 'package:flutter_1/screens/first_page.dart';
import 'package:flutter_1/screens/sell_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: FirstPage(),
    );
  }


}

