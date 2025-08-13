
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/status_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/video_downloader.dart';

class InstagramDownloadPage extends ConsumerStatefulWidget {
  const InstagramDownloadPage({super.key});

  @override
  ConsumerState<InstagramDownloadPage> createState() => _InstagramDownloadPageState();
}

class _InstagramDownloadPageState extends ConsumerState<InstagramDownloadPage> {
  final _controller = TextEditingController();
  double _progress = 0;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحميل من انستغرام')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'https://instagram.com/...'),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progress == 0 || _progress == 1 ? null : _progress),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                setState(() { _progress = 0; _message = null; });
                try {
                  final svc = VideoDownloaderService();
                  final parsed = await svc.parse(_controller.text);
                  final dir = await getExternalStorageDirectory();
                  final file = await svc.downloadToFile(parsed, dir!, onProgress: (r,t){ setState((){ _progress = t>0 ? r/t : 0;});});
                  if (mounted) {
                    setState(() { _message = 'تم التحميل: ${file.path}';});
                    // refresh saved list
                    await ref.read(whatsappStatusesProvider.notifier).saveToAppFolder(file.path);
                  }
                } catch (e) {
                  setState(() { _message = 'فشل: $e';});
                }
              },
              child: const Text('تحميل'),
            ),
            if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message!)),
          ],
        ),
      ),
    );
  }
}


