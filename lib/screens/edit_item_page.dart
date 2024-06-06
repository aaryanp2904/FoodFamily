import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../item_model.dart';

class EditItemPage extends StatefulWidget {
  final Item item;
  final VoidCallback onSubmit;

  const EditItemPage({
    super.key,
    required this.item,
    required this.onSubmit,
  });

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _expiryDateController;
  late TextEditingController _descriptionController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price);
    _expiryDateController = TextEditingController(text: widget.item.expiryDate);
    _descriptionController = TextEditingController(text: widget.item.description);
    _tags = List.from(widget.item.tags);
  }

  Future<void> _saveListing() async {
    try {
      final updatedItem = widget.item.copyWith(
        name: _nameController.text,
        price: _priceController.text,
        expiryDate: _expiryDateController.text,
        description: _descriptionController.text,
        tags: _tags,
      );

      await FirebaseFirestore.instance
          .collection('items')
          .doc(updatedItem.id)
          .update(updatedItem.toFirestore());

      widget.onSubmit(); // Call the onSubmit callback to refresh listings
      Navigator.of(context).pop(); // Go back to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating listing: $e')));
    }
  }

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _expiryDateController,
              decoration: const InputDecoration(labelText: 'Expiry Date'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            TextField(
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addTag(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Add Tag',
                suffixIcon: Icon(Icons.add),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 43, 173, 199),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _saveListing,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
