import 'dart:io';

class Item {
  final String name;
  final List<String> photos;
  final String price;
  final String expiryDate;
  final String description;
  final List<String> tags;

  Item(
      {required this.name,
      required this.photos,
      required this.price,
      required this.expiryDate,
      required this.description,
      required this.tags});

  factory Item.fromFirestore(Map<String, dynamic> data) {
    return Item(
      name: data['name'],
      photos: List<String>.from(data['images']),
      price: data['price'],
      expiryDate: data['expiryDate'],
      description: data['description'],
      tags: data['tags'].from(data['tags']),
    );
  }
}
