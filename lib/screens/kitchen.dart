import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_kitchen_item_page.dart';
import '../item_model.dart'; // Import Item model
import 'invite_user_page.dart';

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

  late String kitchenId;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _initializeKitchen();
  }

  Future<void> _initializeKitchen() async {
    final user = _auth.currentUser!;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('kitchenId')) {
      setState(() {
        kitchenId = userDoc['kitchenId'];
        _isLoading = false;
      });
    } else {
      final newKitchenRef = FirebaseFirestore.instance.collection('Kitchens').doc();
      await newKitchenRef.set({
        'kitchenId': newKitchenRef.id,
        'members': [user.uid]
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'kitchenId': newKitchenRef.id
      }, SetOptions(merge: true));

      setState(() {
        kitchenId = newKitchenRef.id;
        _isLoading = false;
      });
    }

    _checkForInvitations(user.uid);
  }

  Future<void> _checkForInvitations(String userId) async {
    final invitations = await FirebaseFirestore.instance
        .collection('invitations')
        .where('invitedUserId', isEqualTo: userId)
        .get();

    if (invitations.docs.isNotEmpty) {
      final invitation = invitations.docs.first;
      final invitedBy = invitation['invitedBy'];
      final kitchenId = invitation['kitchenId'];

      final invitedByUser = await FirebaseFirestore.instance.collection('users').doc(invitedBy).get();
      final invitedByName = invitedByUser['email'];

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kitchen Invitation'),
          content: Text('$invitedByName has invited you to join their kitchen.'),
          actions: [
            TextButton(
              onPressed: () {
                invitation.reference.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'kitchenId': kitchenId,
                });
                await FirebaseFirestore.instance.collection('Kitchens').doc(kitchenId).update({
                  'members': FieldValue.arrayUnion([userId])
                });
                invitation.reference.delete();
                setState(() {
                  this.kitchenId = kitchenId;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _leaveKitchen() async {
    final user = _auth.currentUser!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Kitchen'),
        content: const Text('Are you sure you want to leave the current kitchen?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              // Create a new kitchen
              final newKitchenRef = FirebaseFirestore.instance.collection('Kitchens').doc();
              await newKitchenRef.set({
                'kitchenId': newKitchenRef.id,
                'members': [user.uid]
              });
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'kitchenId': newKitchenRef.id
              });

              // Remove the user from the current kitchen
              await FirebaseFirestore.instance.collection('Kitchens').doc(kitchenId).update({
                'members': FieldValue.arrayRemove([user.uid])
              });

              setState(() {
                kitchenId = newKitchenRef.id;
              });
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberEmails() async {
    final kitchenDoc = await FirebaseFirestore.instance.collection('Kitchens').doc(kitchenId).get();
    final memberIds = List<String>.from(kitchenDoc['members']);
    final memberEmails = await Future.wait(memberIds.map((memberId) async {
      final memberDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
      return memberDoc['email'];
    }));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitchen Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: memberEmails.map((email) => Text(email)).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Show a loading indicator while initializing
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Kitchen'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Kitchen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: _leaveKitchen,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            onPressed: _showMemberEmails,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InviteUserPage(kitchenId: kitchenId)),
              );
            },
          ),
        ],
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
                  .where('kitchenId', isEqualTo: kitchenId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var items = snapshot.data!.docs.map((doc) => Item.fromFirestore(doc)).toList();
                var filteredItems = items
                    .where((item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                    (_selectedTags.isEmpty || item.tags.any((tag) => _selectedTags.contains(tag))))
                    .toList();

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
                                          children: item.tags.map((tag) => Chip(label: Text(tag))).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
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
              builder: (context) => AddKitchenItemPage(
                onSubmit: () {
                  setState(() {});
                },
                kitchenId: kitchenId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
