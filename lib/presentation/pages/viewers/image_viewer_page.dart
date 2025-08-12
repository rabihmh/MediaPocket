import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../providers/status_providers.dart';

class ImageViewerPage extends ConsumerWidget {
  final String path;
  final String heroTag;
  const ImageViewerPage({super.key, required this.path, required this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Hero(
        tag: heroTag,
        child: PhotoView(imageProvider: FileImage(File(path))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await ref.read(statusRepositoryProvider).saveToGallery(path);
          if (ok) {
            await ref.read(whatsappStatusesProvider.notifier).saveToAppFolder(path);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to gallery and app folder')));
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save')));
            }
          }
        },
        icon: const Icon(Icons.download_rounded),
        label: const Text('Save'),
      ),
    );
  }
}


