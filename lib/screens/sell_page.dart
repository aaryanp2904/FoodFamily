import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_1/screens/item_detail_for_sell_page.dart';
import 'package:provider/provider.dart';
import 'list_new_item.dart';
import '../item_provider.dart';
import '../item_model.dart'; // Import Item model
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:flutter/services.dart'; // Import Clipboard class

class SellPage extends StatefulWidget {
  final VoidCallback onSubmit;
  final ValueNotifier<bool> isDarkMode;

  const SellPage({super.key, required this.onSubmit, required this.isDarkMode});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchUserItems();
  }

  void _fetchUserItems() async {
    final user = _auth.currentUser;
    if (user != null) {
      await Provider.of<ItemProvider>(context, listen: false)
          .fetchUserItems(user.uid);
    }
  }

  Future<void> _handleAcceptEnquiry(Item item) async {
    print('Handling accept enquiry for item: ${item.name}');
    if (item.enquiries.isNotEmpty) {
      final firstEnquirer = item.enquiries.entries.first;
      final String enquirerName = firstEnquirer.key;
      final String enquirerId = firstEnquirer.value;

      print('Enquirer: $enquirerName, ID: $enquirerId');

      // Fetch enquirer's phone number
      final String? enquirerPhoneNumber =
      await _getEnquirerPhoneNumber(enquirerId);

      if (enquirerPhoneNumber != null) {
        // Empty the enquiries queue
        item.enquiries.clear();

        // Set contact message
        item.contactMessage = 'Contact $enquirerName at +$enquirerPhoneNumber';

        // Update Firestore
        final DocumentReference itemDoc =
        FirebaseFirestore.instance.collection('items').doc(item.id);
        await itemDoc.update(item.toFirestore());

        // Update state to show contact message
        setState(() {
          // Item state is already updated before Firestore update
        });

        print('Updated contact message: ${item.contactMessage}');
      } else {
        print('Failed to fetch phone number for enquirer ID: $enquirerId');
      }
    } else {
      print('No enquiries to accept for item: ${item.name}');
    }
  }

  Future<void> _handleRemoveEnquiry(Item item) async {
    print('Handling remove enquiry for item: ${item.name}');
    await _removeEnquirer(item);
  }

  Future<void> _removeEnquirer(Item item) async {
    if (item.enquiries.isNotEmpty) {
      final firstEnquirer = item.enquiries.entries.first;
      print('Removing enquirer: ${firstEnquirer.key}');
      item.enquiries.remove(firstEnquirer.key);

      // Update Firestore
      final DocumentReference itemDoc =
      FirebaseFirestore.instance.collection('items').doc(item.id);
      await itemDoc.update(item.toFirestore());

      // Update state
      setState(() {});
    } else {
      print('No enquiries to remove for item: ${item.name}');
    }
  }

  Future<String?> _getEnquirerPhoneNumber(String userId) async {
    try {
      print('Fetching phone number for user ID: $userId');
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        print('Phone number fetched: ${userData['phone']}');
        return userData['phone'] as String?;
      } else {
        print('User not found for userId: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user phone number: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final items = itemProvider.userItems;
    final filteredItems = items
        .where((item) =>
    item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
        (_selectedTags.isEmpty ||
            item.tags.any((tag) => _selectedTags.contains(tag))))
        .toList();
    final screenWidth = MediaQuery.of(context).size.width;

    print('Building UI with items:');
    for (var item in filteredItems) {
      print('Item: ${item.name}, Contact Message: ${item.contactMessage}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
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
              ]
                  .map((tag) => Padding(
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
              ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final firstEnquirer = item.enquiries.isNotEmpty
                    ? item.enquiries.entries.first
                    : null;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailForSellPage(
                          item: item,
                          isDarkMode: widget.isDarkMode,
                          onSubmit: widget.onSubmit, // Pass the callback
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
                                    item.photos[0], // Use URL directly
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    const SizedBox(height: 5),
                                    if (item.contactMessage == null)
                                      Text(
                                        'Enquiries: ${item.enquiries.length}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (item.contactMessage != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.contactMessage!,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.copy),
                                            onPressed: () {
                                              Clipboard.setData(
                                                  ClipboardData(
                                                      text: '${item.contactMessage!
                                                          .split(' at ')[1]}'));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Phone number copied to clipboard!'),
                                              ));
                                            },
                                          ),
                                        ],
                                      ),
                                    if (firstEnquirer != null &&
                                        item.contactMessage == null) ...[
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Enquirer: ${firstEnquirer.key}',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.check,
                                                color: Colors.green),
                                            onPressed: () =>
                                                _handleAcceptEnquiry(item),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _handleRemoveEnquiry(item),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 5,
                                      children: item.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag),
                                          backgroundColor:
                                          widget.isDarkMode.value
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListNewItemPage(onSubmit: () {
                widget.onSubmit();
              }),
            ),
          );
        },
        backgroundColor: const Color(0xff309fa9),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
