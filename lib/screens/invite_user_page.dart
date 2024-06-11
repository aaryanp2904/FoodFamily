import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InviteUserPage extends StatefulWidget {
  final String kitchenId;

  const InviteUserPage({Key? key, required this.kitchenId}) : super(key: key);

  @override
  _InviteUserPageState createState() => _InviteUserPageState();
}

class _InviteUserPageState extends State<InviteUserPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _showError = false;
  String _errorMessage = '';

  Future<void> _inviteUser() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter an email address.';
      });
      return;
    }

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'No user found with that email.';
      });
      return;
    }

    final userId = userSnapshot.docs.first.id;
    final currentUser = FirebaseAuth.instance.currentUser!;

    // Create an invitation in the invitations collection
    try {
      await FirebaseFirestore.instance.collection('invitations').add({
        'kitchenId': widget.kitchenId,
        'invitedBy': currentUser.uid,
        'invitedUserId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _showError = true;
        _errorMessage = 'An error occurred while inviting the user. Please try again.';
      });
      print('Error inviting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'User Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_showError)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _inviteUser,
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }
}
