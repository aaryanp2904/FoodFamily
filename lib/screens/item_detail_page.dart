import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'directions_page.dart'; // Import the directions page

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
  String? _userAccommodation;

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
          });
        }
      }
    }
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

  Future<void> _openDirections() async {
    final locationData = await Location().getLocation();
    final destination = _accommodationLocations[widget.item.accommodation];
    
    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DirectionsPage(
            destination: destination,
          ),
        ),
      );
    }
  }

  final Map<String, LatLng> _accommodationLocations = {
    'Beit Quad': const LatLng(51.4999578, -0.1786947),
    'Gabor Hall': const LatLng(51.4994998, -0.1722478),
    'Linstead Hall': const LatLng(51.499768, -0.1720874),
    'Wilkinson Hall': const LatLng(51.499629, -0.1720501),
    'Kemp Porter Buildings': const LatLng(51.5099, -0.2699),
    'Falmouth Hall': const LatLng(51.4986411, -0.172552),
    'Keogh Hall': const LatLng(51.4985492, -0.1730125),
    'Selkirk Hall': const LatLng(51.4985999, -0.1725462),
    'Tizard Hall': const LatLng(51.4986622, -0.1724472),
    'Wilson House': const LatLng(51.5169551, -0.1700866),
    'Woodward Buildings': const LatLng(51.5131, -0.2704),
  };

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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_userAccommodation != null &&
                    _accommodationLocations[_userAccommodation!] != null)
                  ElevatedButton(
                    onPressed: _openDirections,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      textStyle: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                    child: const Text('Get Directions'),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleEnquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    textStyle: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                  child: const Text('Send Enquiry'),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    _enquiryMessage,
                    style: TextStyle(
                      color: _isEnquiryError ? Colors.red : Colors.green,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
