import 'package:flutter/material.dart';
import 'list_new_item.dart';

class SellPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const SellPage({super.key, required this.onSubmit});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListNewItemPage(onSubmit: () {
                  widget.onSubmit();
                }),
              ),
            );
          },
          child: const Text('List New Item'),
        ),
      ),
    );
  }
}
