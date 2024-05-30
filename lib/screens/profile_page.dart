import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final ValueNotifier<bool> isDarkMode;

  const ProfilePage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode', style: TextStyle(fontSize: 18)),
                ValueListenableBuilder(
                  valueListenable: isDarkMode,
                  builder: (context, isDark, child) {
                    return Switch(
                      value: isDark,
                      onChanged: (value) {
                        isDarkMode.value = value;
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Profile Page')),
          ],
        ),
      ),
    );
  }
}
