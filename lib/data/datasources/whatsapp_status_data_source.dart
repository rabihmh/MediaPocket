import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class WhatsappStatusDataSource {
  // Common WhatsApp status directories across versions/business app
  static const List<String> possibleStatusDirs = [
    // Newer Android 11+
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    '/storage/self/primary/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/self/primary/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/sdcard/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    // Legacy paths
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
    '/sdcard/WhatsApp/Media/.Statuses',
    '/sdcard/WhatsApp Business/Media/.Statuses',
  ];

  Directory? resolveExistingStatusDir() {
    for (final path in possibleStatusDirs) {
      final dir = Directory(path);
      if (dir.existsSync()) return dir;
    }
    return null;
  }

  static const MethodChannel _channel = MethodChannel('com.statussaver.gallery');

  Future<List<File>> queryImagesViaMediaStoreToCache() async {
    final List<dynamic> list = await _channel.invokeMethod('queryStatusesImages');
    return list.map((e) => File(e['path'] as String)).toList();
  }

  Future<List<File>> queryVideosViaMediaStoreToCache() async {
    final List<dynamic> list = await _channel.invokeMethod('queryStatusesVideos');
    return list.map((e) => File(e['path'] as String)).toList();
  }

  // Storage Access Framework fallbacks
  Future<bool> pickStatusesDirectoryOnce() async {
    final bool ok = await _channel.invokeMethod('pickStatusesTree');
    return ok;
  }

  Future<bool> hasPickedTree() async {
    final bool ok = await _channel.invokeMethod('hasPickedTree');
    return ok;
  }

  Future<List<File>> listFromPickedTreeImages() async {
    final List<dynamic> list = await _channel.invokeMethod('listFromPickedTreeImages');
    return list.map((e) => File(e['path'] as String)).toList();
  }

  Future<List<File>> listFromPickedTreeVideos() async {
    final List<dynamic> list = await _channel.invokeMethod('listFromPickedTreeVideos');
    return list.map((e) => File(e['path'] as String)).toList();
  }

  List<File> listImageFiles(Directory dir) {
    final files = dir
        .listSync(followLinks: true)
        .whereType<File>()
        .where((f) {
          final ext = p.extension(f.path).toLowerCase();
          return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
        })
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  List<File> listVideoFiles(Directory dir) {
    final files = dir
        .listSync(followLinks: true)
        .whereType<File>()
        .where((f) => p.extension(f.path).toLowerCase() == '.mp4')
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }
}


