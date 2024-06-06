import 'dart:io';
import 'package:flutter/material.dart';
import 'item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _marketplaceItems = [];
  List<Item> _userItems = [];

  List<Item> get marketplaceItems => _marketplaceItems;
  List<Item> get userItems => _userItems;

  ItemProvider() {
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('items').get();
      final FirebaseAuth auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user != null) {
        _marketplaceItems = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
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
            contactMessage: data['contactMessage'], // Fetch contactMessage
          );
        }).toList();
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  Future<void> fetchUserItems(String userId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: userId)
          .get();
      _userItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
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
          contactMessage: data['contactMessage'], // Fetch contactMessage
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching user items: $e');
    }
  }

  void addItem(Item item) {
    _userItems.add(item);
    _marketplaceItems.add(item);
    notifyListeners();
  }
}
