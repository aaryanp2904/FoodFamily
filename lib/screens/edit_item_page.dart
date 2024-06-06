import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../item_model.dart';
import 'dart:io';

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
  final List<File> _images = [];
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price);
    _expiryDateController = TextEditingController(text: widget.item.expiryDate);
    _descriptionController = TextEditingController(text: widget.item.description);
    _tags = List.from(widget.item.tags);
    _imageUrls.addAll(widget.item.photos);
  }

  Future<void> _saveListing() async {
    try {
      List<String> imageUrls = List.from(_imageUrls);

      for (var image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = FirebaseStorage.instance.ref().child('items/$fileName');
        UploadTask uploadTask = reference.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        if (taskSnapshot.state == TaskState.success) {
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to upload image')));
          }
          return;
        }
      }

      final updatedItem = widget.item.copyWith(
        name: _nameController.text,
        price: _priceController.text,
        expiryDate: _expiryDateController.text,
        description: _descriptionController.text,
        tags: _tags,
        photos: imageUrls,
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
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        File compressedImage = await _compressImage(File(pickedFile.path));
        setState(() {
          _images.add(compressedImage);
        });
      }
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
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
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.remove(image);
                            });
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _imageUrls.map((url) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageUrls.remove(url);
                            });
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  prefixText: '£',
                  hintText: 'Enter price',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                ].map((tag) => ChoiceChip(
                  label: Text(tag),
                  selected: _tags.contains(tag),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveListing,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Save Changes'),
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
                    }),
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
        });
  }
}
