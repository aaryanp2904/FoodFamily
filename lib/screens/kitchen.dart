import 'package:flutter/material.dart';

class Kitchen extends StatelessWidget {
  final ValueNotifier<bool> isDarkMode;

  const Kitchen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Kitchen'),
      ),
      body: Center(
        child: Text('Welcome to the Kitchen!'),
      ),
    );
  }
}
