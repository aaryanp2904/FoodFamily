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
  final String accommodation;
  String? contactMessage; // Make this field mutable
  String kitchenId;

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
    required this.accommodation,
    required this.kitchenId,
    this.contactMessage,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'],
      photos: List<String>.from(data['images']),
      price: data['price'] ?? "0",
      expiryDate: data['expiryDate'],
      description: data['description'] ?? "",
      tags: List<String>.from(data['tags']),
      userId: data['userId'] ?? "",
      enquiries: Map<String, String>.from(data['enquiries'] ?? {}),
      contactMessage: data['contactMessage'],
      accommodation: data['accommodation'] ?? "",
      kitchenId: data['kitchenId'],
    );
  }

  get images => null;


  Item copyWith({
    String? id,
    String? name,
    String? price,
    String? expiryDate,
    String? description,
    List<String>? tags,
    List<String>? photos,
    String? userId,
    Map<String, String>? enquiries,
    String? contactMessage,
    String? accommodation,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
      userId: userId ?? this.userId,
      enquiries: enquiries ?? this.enquiries,
      contactMessage: contactMessage ?? this.contactMessage,
      accommodation: accommodation ?? this.accommodation,
      kitchenId: kitchenId,
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
      'accommodation': accommodation,
      'kitchenId': kitchenId,
    };
  }
}
