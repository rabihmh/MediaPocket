import 'package:flutter/material.dart';

class TiktokSoonPage extends StatelessWidget {
  const TiktokSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TikTok')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Available Soon', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}


