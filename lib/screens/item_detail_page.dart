import 'package:flutter/material.dart';
import '../item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;
  final ValueNotifier<bool> isDarkMode;

  const ItemDetailPage({super.key, required this.item, required this.isDarkMode});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  bool _isEnquirySuccessful = false;
  bool _isEnquiryError = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _enquiryMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  Future<String?> getUserNameByItem(Item item) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(item.userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['fullName'] as String?;
      } else {
        print('User not found for userId: ${item.userId}');
        return null;
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  Future<String?> getUserNameById(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['fullName'] as String?;
      } else {
        print('User not found for userId: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  Future<void> _handleEnquiry() async {
    // Get Current User
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) return;

    // Check if the user is trying to enquire their own listing
    if (widget.item.userId == user.uid) {
      setState(() {
        _isEnquirySuccessful = false;
        _isEnquiryError = true;
        _enquiryMessage = 'You cannot enquire to your own listing';
      });
      _controller.forward();
      return;
    }

    setState(() {
      _isEnquirySuccessful = true;
      _isEnquiryError = false;
    });

    final String currentUserId = user.uid;
    final String? currentUserName = await getUserNameById(currentUserId);

    if (currentUserName != null) {
      // Add enquiry to the Firestore document
      final DocumentReference itemDoc =
      FirebaseFirestore.instance.collection('items').doc(widget.item.id);

      await itemDoc.update({
        'enquiries.${currentUserName}': currentUserId,
      });

      String? sellerName = await getUserNameByItem(widget.item);

      setState(() {
        widget.item.enquiries[currentUserName] = currentUserId;
        _enquiryMessage =
        'Enquiry Successful.\nLook out for a text message from ${sellerName ?? 'the seller'}.';
      });

      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.isDarkMode,
        builder: (context, isDark, child) {
          return SingleChildScrollView(
            child: Padding(
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
                  AspectRatio(
                    aspectRatio: 1,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: _isEnquirySuccessful || _isEnquiryError
                        ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: _isEnquiryError ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _enquiryMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: _handleEnquiry,
                      child: const Text(
                        'Enquire',
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
        },
      ),
    );
  }
}
