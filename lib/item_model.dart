import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final List<String> photos;
  final String price;
  final String expiryDate;
  final String description;
  final List<String> tags;
  final String userId;
  final Map<String, String> enquiries;
  String? contactMessage; // Make this field mutable

  Item({
    required this.id,
    required this.name,
    required this.photos,
    required this.price,
    required this.expiryDate,
    required this.description,
    required this.tags,
    required this.userId,
    required this.enquiries,
    this.contactMessage,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'],
      photos: List<String>.from(data['images']),
      price: data['price'],
      expiryDate: data['expiryDate'],
      description: data['description'],
      tags: List<String>.from(data['tags']),
      userId: data['userId'],
      enquiries: Map<String, String>.from(data['enquiries'] ?? {}),
      contactMessage: data['contactMessage'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'images': photos,
      'price': price,
      'expiryDate': expiryDate,
      'description': description,
      'tags': tags,
      'userId': userId,
      'enquiries': enquiries,
      'contactMessage': contactMessage,
    };
  }
}




