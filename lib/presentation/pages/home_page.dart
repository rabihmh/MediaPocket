import 'package:flutter/material.dart';

import 'tabs/instagram_soon_page.dart';
import 'tabs/tiktok_soon_page.dart';
import 'tabs/whatsapp/whatsapp_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const WhatsappPage(),
      const InstagramSoonPage(),
      const TiktokSoonPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'WhatsApp'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), label: 'Instagram'),
          NavigationDestination(icon: Icon(Icons.music_note_outlined), label: 'TikTok'),
        ],
      ),
    );
  }
}


