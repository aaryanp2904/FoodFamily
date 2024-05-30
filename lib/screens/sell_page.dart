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
        title: const Text('Sell Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text('List your items for sale',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add, size: 32),
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
