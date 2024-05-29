import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../item_provider.dart';
import '../item_model.dart';

class SellPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const SellPage({super.key, required this.onSubmit});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final List<File> _images = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      final pickedFiles = await picker.pickMultiImage();
      setState(() {
        _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      });
        } else if (source == ImageSource.camera) {
      bool continueTakingPhotos = true;

      while (continueTakingPhotos) {
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _images.add(File(pickedFile.path));
          });
        } else {
          continueTakingPhotos = false;
        }

        continueTakingPhotos = await _showContinueTakingPhotosDialog();
      }
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
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
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

  void _submitItem() {
    if (_nameController.text.isEmpty || _images.isEmpty || _priceController.text.isEmpty || _expiryDateController.text.isEmpty) {
      // Show an error message or handle the validation as needed
      showDialog(context: context, builder: (context) => const AlertDialog(title: Text('Missing Fields'), content: Text('Make sure to fill out ALL fields, including photo.'),));
      return;
    }

    final item = Item(
      name: _nameController.text,
      photos: _images,
      price: _priceController.text,
      expiryDate: _expiryDateController.text,
    );

    Provider.of<ItemProvider>(context, listen: false).addItem(item);

    // Call the onSubmit callback to navigate to the Marketplace screen
    widget.onSubmit();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                _showPicker(context);
              },
              child: const Text('Upload/Take Photo (*)'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _images.map((image) {
                return Image.file(
                  image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Item Name (*)'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Price (*)'),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixText: '£',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Expiry Date (*)'),
            TextField(
              controller: _expiryDateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                await _selectDate(context);
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitItem,
                child: const Text('Submit'),
              ),
            ),
          ],
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
