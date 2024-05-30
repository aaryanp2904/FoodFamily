import 'dart:io';

import 'package:flutter/material.dart';
import 'item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  ItemProvider() {
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('items').get();
      _items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item(
          name: data['name'],
          photos: (data['images'] as List).map((url) => File(url)).toList(),
          price: data['price'],
          expiryDate: data['expiryDate'],
          description: data['description'],
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void addItem(Item item) {
    _items.add(item);
    notifyListeners();
  }
}
