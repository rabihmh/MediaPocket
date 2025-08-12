import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class StoragePermissionService {
  Future<bool> ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // If already granted, short-circuit
    final alreadyGranted = await _isAnyGranted();
    if (alreadyGranted) return true;

    // Try requesting modern scoped permissions (Android 13+)
    try {
      await Permission.photos.request();
    } catch (_) {}
    try {
      await Permission.videos.request();
    } catch (_) {}

    // Also request legacy storage permission for Android <= 12
    try {
      await Permission.storage.request();
    } catch (_) {}

    // Evaluate again after requests
    return _isAnyGranted();
  }

  Future<bool> _isAnyGranted() async {
    final photos = await Permission.photos.status;
    final videos = await Permission.videos.status;
    final storage = await Permission.storage.status;
    return photos.isGranted && videos.isGranted || storage.isGranted;
  }
}


