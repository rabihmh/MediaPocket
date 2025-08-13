import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InstagramSoonPage extends StatelessWidget {
  const InstagramSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = accentGradient();
    return Scaffold(
      appBar: AppBar(title: const Text('التحميل من انستغرام')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text('انسخ رابط الصورة، الفيديو، أو الريلز من انستغرام والصقه هنا للتحميل.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'https://instagram.com...'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14)),
                child: TextButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('تحميل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


