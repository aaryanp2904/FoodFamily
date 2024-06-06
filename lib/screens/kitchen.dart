import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_kitchen_item_page.dart';
import '../item_model.dart'; // Import Item model

class Kitchen extends StatefulWidget {
  final ValueNotifier<bool> isDarkMode;

  const Kitchen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _KitchenState createState() => _KitchenState();
}

class _KitchenState extends State<Kitchen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Kitchen',
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
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('KitchenItems')
                  .where('userId', isEqualTo: _auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var items = snapshot.data!.docs.map((doc) => Item.fromFirestore(doc)).toList();
                var filteredItems = items.where((item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                    (_selectedTags.isEmpty || item.tags.any((tag) => _selectedTags.contains(tag)))).toList();

                filteredItems.sort((a, b) {
                  DateTime aExpiry = DateTime.parse(a.expiryDate);
                  DateTime bExpiry = DateTime.parse(b.expiryDate);
                  return aExpiry.compareTo(bExpiry);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    var item = filteredItems[index];
                    return GestureDetector(
                      onTap: () {
                        // Implement your item detail page navigation
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
                                        Text(
                                          "Expiry: ${item.expiryDate}",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.grey,
                                          ),
                                        ),
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
                builder: (context) => AddKitchenItemPage(onSubmit: () {
                  setState(() {});
                })),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
