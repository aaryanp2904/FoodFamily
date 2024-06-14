import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../item_provider.dart';
import 'item_detail_page.dart';
import 'map_page.dart';

class Marketplace extends StatefulWidget {
  final ValueNotifier<bool> isDarkMode;

  const Marketplace({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _MarketplaceState createState() => _MarketplaceState();
  
}

class _MarketplaceState extends State<Marketplace> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _selectedTags = [];
  String? _userAccommodation;
  String? _selectedAccommodation;

  final List<String> _accommodations = [
    'Beit Quad',
    'Gabor Hall',
    'Linstead Hall',
    'Wilkinson Hall',
    'Kemp Porter Buildings',
    'Falmouth Hall',
    'Keogh Hall',
    'Selkirk Hall',
    'Tizard Hall',
    'Wilson House',
    'Woodward Buildings'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAccommodation();
  }

  Future<void> _loadUserAccommodation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _userAccommodation = data['accommodation'];
            _selectedAccommodation = _userAccommodation;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final items = itemProvider.marketplaceItems;
    final filteredItems = items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            (_selectedTags.isEmpty ||
                item.tags.any((tag) => _selectedTags.contains(tag))) &&
            (_selectedAccommodation == null || item.accommodation == _selectedAccommodation))
        .toList();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.isDarkMode,
        builder: (context, isDark, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedAccommodation,
                      hint: const Text('Select Accommodation'),
                      items: _accommodations.map((accommodation) {
                        return DropdownMenuItem<String>(
                          value: accommodation,
                          child: Text(accommodation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccommodation = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  ].map((tag) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChoiceChip(
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
                        ),
                      )).toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailPage(
                              item: item,
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        item.photos[0],
                                        width: screenWidth * 0.4,
                                        height: screenWidth * 0.4,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "£${item.price}",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "Expiry: ${item.expiryDate}",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 5,
                                          children: item.tags.map((tag) {
                                            return Chip(
                                              label: Text(tag),
                                              backgroundColor: isDark
                                                  ? Colors.grey.shade700
                                                  : Colors.blue.shade100,
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
