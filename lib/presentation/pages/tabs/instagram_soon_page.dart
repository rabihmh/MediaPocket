import 'package:flutter/material.dart';

class InstagramSoonPage extends StatelessWidget {
  const InstagramSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instagram')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Available Soon', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}


