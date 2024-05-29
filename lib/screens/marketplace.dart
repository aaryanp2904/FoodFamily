import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../item_provider.dart';

class Marketplace extends StatelessWidget {
  const Marketplace({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).primaryColor,
          child: Row(
            children: [
              Image.file(
                item.photos[0],
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10), // Add some space between the image and the text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(fontSize: screenWidth * 0.1), // Adjust text size
                    ),
                    SizedBox(height: 10), // Add some space between text and row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("£${item.price}"),
                        Text(item.expiryDate),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

