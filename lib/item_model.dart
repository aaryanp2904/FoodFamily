import 'dart:io';

class Item {
  final String name;
  final List<File> photos;
  final String price;
  final String expiryDate;

  Item({
    required this.name,
    required this.photos,
    required this.price,
    required this.expiryDate,
  });
}
