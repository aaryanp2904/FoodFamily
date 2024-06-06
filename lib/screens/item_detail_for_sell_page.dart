import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../item_model.dart';
import 'edit_item_page.dart'; // Import the edit item page

class ItemDetailForSellPage extends StatefulWidget {
  final Item item;
  final ValueNotifier<bool> isDarkMode;
  final VoidCallback onSubmit;

  const ItemDetailForSellPage({
    super.key,
    required this.item,
    required this.isDarkMode,
    required this.onSubmit,
  });

  @override
  _ItemDetailForSellPageState createState() => _ItemDetailForSellPageState();
}

class _ItemDetailForSellPageState extends State<ItemDetailForSellPage> {
  int _currentPage = 0;

  Future<void> _removeListing() async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.item.id)
          .delete();
      widget.onSubmit(); // Call the onSubmit callback to refresh listings
      Navigator.of(context).pop(); // Go back to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing removed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error removing listing: $e')));
    }
  }

  Future<void> _editListing() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditItemPage(
          item: widget.item,
          onSubmit: widget.onSubmit,
        ),
      ),
    );
    setState(() {}); // Refresh the page after editing
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.isDarkMode,
        builder: (context, isDark, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Photo ${_currentPage + 1} of ${widget.item.photos.length}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SizedBox(
                    height: screenWidth * 0.8,
                    child: PageView.builder(
                      itemCount: widget.item.photos.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final photoUrl = widget.item.photos[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  photoUrl,
                                  width: screenWidth * 0.8,
                                  height: screenWidth * 0.8,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Name: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.item.name,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Price: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "£${widget.item.price}",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Expiry Date: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.item.expiryDate,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.item.description,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tags:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 5,
                          children: widget.item.tags.map((tag) {
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
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 43, 173, 199),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _removeListing,
                          child: const Text(
                            'Remove Listing',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _editListing,
                          child: const Text(
                            'Edit Listing',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
