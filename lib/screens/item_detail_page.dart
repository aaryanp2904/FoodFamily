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
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display all photos
                      SizedBox(
                        height: screenWidth, // Adjust the height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: item.photos.length,
                          itemBuilder: (context, index) {
                            final photo = item.photos[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: kIsWeb
                                  ? Image.network(
                                      photo.path,
                                      width: screenWidth * 0.15,
                                      height: screenWidth * 0.15,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      photo,
                                      width: screenWidth,
                                      height:
                                          screenWidth, // Maintain aspect ratio
                                      fit: BoxFit.cover,
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Name: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(fontSize: screenWidth * 0.045),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Price: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "£${item.price}",
                              style: TextStyle(fontSize: screenWidth * 0.045),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Text(
                            'Expiry Date: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.expiryDate,
                              style: TextStyle(fontSize: screenWidth * 0.045),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          item.description,
                          style: TextStyle(fontSize: screenWidth * 0.045),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Handle button press
                },
                child: const Text('Enquire'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
