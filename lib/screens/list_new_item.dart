// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../item_provider.dart';
import '../item_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListNewItemPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const ListNewItemPage({super.key, required this.onSubmit});

  @override
  _ListNewItemPageState createState() => _ListNewItemPageState();
}

class _ListNewItemPageState extends State<ListNewItemPage> {
  final List<File> _images = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      final pickedFiles = await picker.pickMultiImage();
      for (var pickedFile in pickedFiles) {
        File compressedImage = await _compressImage(File(pickedFile.path));
        setState(() {
          _images.add(compressedImage);
        });
      }
    } else if (source == ImageSource.camera) {
      bool continueTakingPhotos = true;

      while (continueTakingPhotos) {
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          File compressedImage = await _compressImage(File(pickedFile.path));
          setState(() {
            _images.add(compressedImage);
          });
        } else {
          continueTakingPhotos = false;
        }

        continueTakingPhotos = await _showContinueTakingPhotosDialog();
      }
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    if (result != null) {
      return File(result.path);
    } else {
      return file;
    }
  }

  Future<bool> _showContinueTakingPhotosDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Continue Taking Photos?'),
              content: const Text('Would you like to take another photo?'),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _expiryDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _submitItem() async {
    if (_nameController.text.isEmpty ||
        _images.isEmpty ||
        _priceController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _selectedTags.isEmpty) {
      // Show an error message or handle the validation as needed
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Missing Fields'),
          content: Text(
              'Make sure to fill out ALL fields, including photo and tags.'),
        ),
      );
      return;
    }

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference =
            FirebaseStorage.instance.ref().child('items/$fileName');
        UploadTask uploadTask = reference.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        if (taskSnapshot.state == TaskState.success) {
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
          print('Upload successful: $downloadUrl');
        } else {
          print('Upload failed');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to upload image')));
          }
          return;
        }
      }

      final newItem = FirebaseFirestore.instance
          .collection('items')
          .doc(); // Generate a new document reference
      await newItem.set({
        'id': newItem.id, // Use the document ID
        'name': _nameController.text,
        'price': _priceController.text,
        'expiryDate': _expiryDateController.text,
        'description': _descriptionController.text,
        'images': imageUrls,
        'tags': _selectedTags,
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item listed successfully')));
      }

      Provider.of<ItemProvider>(context, listen: false).addItem(Item(
        id: newItem.id,
        name: _nameController.text,
        photos: imageUrls,
        price: _priceController.text,
        expiryDate: _expiryDateController.text,
        description: _descriptionController.text,
        tags: _selectedTags,
        userId: FirebaseAuth.instance.currentUser!.uid,
        enquiries: {},
        kitchenId: ""
      ));

      if (mounted) {
        Navigator.pop(context);
        widget.onSubmit();
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to list item')));
      }
    }
  }

  void _sendEnquiryNotification(String sellerToken) async {
    final String serverKey =
        'YOUR_FCM_SERVER_KEY'; // Replace with your FCM server key
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(<String, dynamic>{
        'to': sellerToken,
        'notification': <String, dynamic>{
          'title': 'New Enquiry',
          'body': 'Someone has enquired about your item.',
        },
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showPicker(context);
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload/Take Photo (*)'),
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
              const Text('Item Name (*)'),
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
              const Text('Price (*)'),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  prefixText: '£',
                  hintText: 'Enter price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
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
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  await _selectDate(context);
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
                children: [
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
                ]
                    .map((tag) => ChoiceChip(
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
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Fetch seller token from the database (this is just a placeholder)
                    final sellerId =
                        'SELLER_USER_ID'; // Get the seller's user ID
                    final sellerDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(sellerId)
                        .get();
                    if (sellerDoc.exists) {
                      final sellerToken = sellerDoc.data()?[
                          'token']; // Assuming token is stored in the 'token' field
                      if (sellerToken != null) {
                        _sendEnquiryNotification(sellerToken);
                      } else {
                        print('Seller token not found');
                      }
                    } else {
                      print('Seller not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Enquire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
