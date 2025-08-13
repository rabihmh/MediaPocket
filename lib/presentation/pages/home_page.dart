import 'package:flutter/material.dart';

import 'tabs/whatsapp/whatsapp_page.dart';
import 'landing/home_landing_page.dart';
import 'pocket/pocket_page.dart';

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
      const HomeLandingPage(),
      const WhatsappPage(),
      const PocketPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0x141E1E1E),
          border: const Border(top: BorderSide(color: Color(0xFF2F2F2F))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
        ),
        padding: const EdgeInsets.only(top: 8),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'واتساب'),
            NavigationDestination(icon: Icon(Icons.download_outlined), selectedIcon: Icon(Icons.download), label: 'جيبي'),
          ],
        ),
      ),
    );
  }
}


