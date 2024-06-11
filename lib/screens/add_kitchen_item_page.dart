import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class AddKitchenItemPage extends StatefulWidget {
  final VoidCallback onSubmit;
  final String kitchenId;

  const AddKitchenItemPage({super.key, required this.kitchenId, required this.onSubmit});

  @override
  _AddKitchenItemPageState createState() => _AddKitchenItemPageState();
}

class _AddKitchenItemPageState extends State<AddKitchenItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<File> _images = [];
  final List<XFile> _pickedFiles = []; // To store the XFile objects
  bool _showError = false;
  String _errorMessage = '';

  final List<String> _tags = [
    'fruit',
    'dairy',
    'vegetables',
    'meal',
    'frozen',
    'Original Packaging',
    'Organic',
    'Canned',
    'Vegan',
    'Vegetarian',
    'Halal',
    'Kosher',
    'other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _expiryDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Gallery'),
              onTap: () async {
                final pickedFiles = await picker.pickMultiImage();
                if (pickedFiles.isNotEmpty) {
                  setState(() {
                    for (var pickedFile in pickedFiles) {
                      _pickedFiles.add(pickedFile); // Add pickedFile to the list
                      _images.add(File(pickedFile.path));
                    }
                  });
                }
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _pickedFiles.add(pickedFile); // Add pickedFile to the list
                    _images.add(File(pickedFile.path));
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _uploadImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final userId = user.uid;
    final List<String> imageUrls = [];

    for (var image in _pickedFiles) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final destination = 'images/$userId/$fileName';

      if (kIsWeb) {
        // Uploading image from web
        final bytes = await image.readAsBytes();
        final ref = FirebaseStorage.instance.ref(destination);
        final uploadTask = ref.putData(bytes);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } else {
        // Uploading image from mobile
        final ref = FirebaseStorage.instance.ref(destination);
        final uploadTask = ref.putFile(File(image.path));
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }

    return imageUrls;
  }

  void _submitItem() async {
    if (_nameController.text.isEmpty ||
        _images.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _selectedTags.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please fill out all fields and select at least one image and tag.';
      });
      return;
    }

    try {
      List<String> imageUrls = await _uploadImages();

      final newItem = FirebaseFirestore.instance
          .collection('KitchenItems')
          .doc(); // Generate a new document reference
      await newItem.set({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'id': newItem.id, // Use the document ID
        'name': _nameController.text,
        'expiryDate': _expiryDateController.text,
        'description': _descriptionController.text,
        'images': imageUrls,
        'tags': _selectedTags,
        'kitchenId': widget.kitchenId,
      });

      widget.onSubmit();

      Navigator.pop(context);
    } catch (e) {
      print('Error adding item: $e');
      setState(() {
        _showError = true;
        _errorMessage = 'An error occurred while adding the item. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick Images (*)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _images.map((image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                      image.path,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                      image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Name (*)'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Enter item name',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Expiry Date (*)'),
              const SizedBox(height: 8),
              TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  suffixIcon: Icon(Icons.calendar_today),
                  hintText: 'Select expiry date',
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _expiryDateController.text = formattedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Description'),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: 'Enter description',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              const Text('Tags (*)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _tags.map((tag) {
                  return ChoiceChip(
                    label: Text(tag),
                    selected: _selectedTags.contains(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Add Item'),
                ),
              ),
              if (_showError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
