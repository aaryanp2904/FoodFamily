import 'dart:io';

class Item {
  final String name;
  final List<File> photos;
  final String price;
  final String expiryDate;
  final String description;

  Item({
    required this.name,
    required this.photos,
    required this.price,
    required this.expiryDate,
    required this.description
  });

  factory Item.fromFirestore(Map<String, dynamic> data) {
    return Item(
      name: data['name'],
      photos: (data['images'] as List).map((url) => File(url)).toList(),
      price: data['price'],
      expiryDate: data['expiryDate'],
      description: data['description'],
    );
  }
}
