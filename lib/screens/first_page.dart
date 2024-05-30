// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_1/screens/marketplace.dart';
import 'package:flutter_1/screens/profile_page.dart';
import 'package:flutter_1/screens/sell_page.dart';

class FirstPage extends StatefulWidget {
  final ValueNotifier<bool> isDarkMode;

  const FirstPage({super.key, required this.isDarkMode});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _currentPage = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Marketplace(),
      SellPage(onSubmit: () {
        setState(() {
          _currentPage = 0; // Navigate to Marketplace page
        });
      }),
      ProfilePage(isDarkMode: widget.isDarkMode),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/logo.jpg', fit: BoxFit.cover, height: 50),
        ),
      ),
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: navigateBottomBar,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shop_2_rounded),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell_rounded),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
