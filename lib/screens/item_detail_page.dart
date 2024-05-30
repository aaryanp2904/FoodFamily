import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../item_model.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kIsWeb ? Image.network(item.photos[0].path, width: screenWidth*0.15, height: screenWidth*0.15, fit: BoxFit.cover,):
            Image.file(
              item.photos[0],
              width: screenWidth,
              height: screenWidth, // Maintain aspect ratio
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: TextStyle(fontSize: screenWidth * 0.05), // Responsive text size
            ),
            const SizedBox(height: 10),
            Text(
              "£${item.price}",
              style: TextStyle(fontSize: screenWidth * 0.04), // Responsive text size
            ),
            const SizedBox(height: 30),
            Text(
              item.description,
              style: TextStyle(fontSize: screenWidth * 0.04), // Responsive text size
            ),
            const SizedBox(height: 10),
            Text(
              item.expiryDate,
              style: TextStyle(fontSize: screenWidth * 0.04), // Responsive text size
            ),
          ],
        ),
      ),
    );
  }
}