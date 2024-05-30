import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'country_flags.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  final ValueNotifier<bool> isDarkMode;

  const ProfilePage({super.key, required this.isDarkMode});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedAccommodation;
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEditable = true;

  String getFlagEmoji(String countryCode) {
    return countryFlags[countryCode] ?? '';
  }

  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/profile.txt';
  }

  Future<void> _saveToFile(String content) async {
    final path = await _getLocalFilePath();
    final file = File(path);
    await file.writeAsString(content);
  }

  Future<void> _checkIfProfileExists() async {
    final path = await _getLocalFilePath();
    final file = File(path);
    if (await file.exists()) {
      final content = await file.readAsString();
      final lines = content.split('\n');
      if (lines.length >= 4) {
        setState(() {
          _fullNameController.text = lines[0].replaceFirst('Full Name: ', '');
          _countryCodeController.text =
              lines[1].replaceFirst('Country Code: ', '');
          _phoneController.text = lines[2].replaceFirst('Phone Number: ', '');
          selectedAccommodation = lines[3].replaceFirst('Accommodation: ', '');
          _isEditable = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfProfileExists();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Save the data to a local file
      final fullName = _fullNameController.text;
      final countryCode = _countryCodeController.text;
      final phoneNumber = _phoneController.text;
      final accommodation = selectedAccommodation ?? '';

      final content =
          'Full Name: $fullName\nCountry Code: $countryCode\nPhone Number: $phoneNumber\nAccommodation: $accommodation';
      await _saveToFile(content);

      // Disable further editing
      setState(() {
        _isEditable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Mode', style: TextStyle(fontSize: 18)),
                  ValueListenableBuilder(
                    valueListenable: widget.isDarkMode,
                    builder: (context, isDark, child) {
                      return Switch(
                        value: isDark,
                        onChanged: (value) {
                          widget.isDarkMode.value = value;
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Personal Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Full Name', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                enabled: _isEditable,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Phone Number', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _countryCodeController,
                      enabled: _isEditable,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            getFlagEmoji(_countryCodeController.text ?? ''),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        hintText: '+',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(
                            () {}); // Update the flag emoji when the code changes
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: _isEditable,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        if (!RegExp(r'^\d{9,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Accommodation', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                value: selectedAccommodation,
                onChanged: _isEditable
                    ? (String? newValue) {
                        setState(() {
                          selectedAccommodation = newValue;
                        });
                      }
                    : null,
                items: <String>[
                  'Woodward Buildings',
                  'Kemp Porter Buildings',
                  'Eastside Halls',
                  'Southside Halls',
                  'Beit Halls',
                  'Xenia',
                  'Wilsons House'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isEditable ? _saveChanges : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: const Color.fromARGB(255, 43, 173, 199),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
}
