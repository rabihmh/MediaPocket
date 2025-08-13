import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../tabs/instagram_download_page.dart';
import '../tabs/tiktok_download_page.dart';
import '../tabs/whatsapp/whatsapp_page.dart';

class HomeLandingPage extends StatelessWidget {
  const HomeLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = accentGradient();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Image.asset('assets/images/launcher_icon.png', width: 40, height: 40),
                const SizedBox(width: 12),
                const Text('MediaPocket', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('المكان الأمثل لحفظ الوسائط من منصاتك المفضلة.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: '...الصق أي رابط هنا'),
            ),
            const SizedBox(height: 20),
            _LandingCard(
              title: 'تحميل حالات واتساب',
              subtitle: 'عرض وحفظ صور وفيديوهات الحالات',
              trailing: const Icon(Icons.chat_bubble, color: Colors.green),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WhatsappPage())),
            ),
            _LandingCard(
              title: 'التحميل من انستغرام',
              subtitle: 'حفظ الصور، الفيديوهات، والريلز',
              trailing: const Icon(Icons.camera_alt_outlined, color: Colors.pinkAccent),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstagramDownloadPage())),
            ),
            _LandingCard(
              title: 'التحميل من تيك توك',
              subtitle: 'حفظ الفيديوهات بدون علامة مائية',
              trailing: const Icon(Icons.music_note_outlined, color: Colors.cyanAccent),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TiktokDownloadPage())),
            ),
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14)),
              child: TextButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('تحميل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  const _LandingCard({required this.title, required this.subtitle, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        leading: const Icon(Icons.chevron_left),
        trailing: trailing,
      ),
    );
  }
}


