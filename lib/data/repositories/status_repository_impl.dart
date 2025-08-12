import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/status_item.dart';
import '../../domain/repositories/status_repository.dart';
import '../datasources/whatsapp_status_data_source.dart';

class StatusRepositoryImpl implements StatusRepository {
  final WhatsappStatusDataSource dataSource;
  StatusRepositoryImpl(this.dataSource);

  @override
  Future<List<StatusItem>> getWhatsappImages() async {
    // Try MediaStore (no permission required on Android 10+)
    List<File> files = [];
    try {
      files = await dataSource.queryImagesViaMediaStoreToCache();
    } catch (_) {}
    // Fallback to direct dir listing
    if (files.isEmpty) {
      final dir = dataSource.resolveExistingStatusDir();
      if (dir == null) return [];
      files = dataSource.listImageFiles(dir);
    }
    return files
        .map(
          (f) => StatusItem(
            filePath: f.path,
            modifiedAt: f.lastModifiedSync(),
            type: StatusType.image,
          ),
        )
        .toList();
  }

  @override
  Future<List<StatusItem>> getWhatsappVideos() async {
    List<File> files = [];
    try {
      files = await dataSource.queryVideosViaMediaStoreToCache();
    } catch (_) {}
    if (files.isEmpty) {
      final dir = dataSource.resolveExistingStatusDir();
      if (dir == null) return [];
      files = dataSource.listVideoFiles(dir);
    }
    return files
        .map(
          (f) => StatusItem(
            filePath: f.path,
            modifiedAt: f.lastModifiedSync(),
            type: StatusType.video,
          ),
        )
        .toList();
  }

  Future<Directory> _getAppSavedDir() async {
    final base = await getExternalStorageDirectory();
    final target = Directory(p.join(base!.path, 'saved'));
    if (!target.existsSync()) {
      target.createSync(recursive: true);
    }
    return target;
  }

  @override
  Future<List<StatusItem>> getSavedItems() async {
    final dir = await _getAppSavedDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final ext = p.extension(f.path).toLowerCase();
          return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.mp4';
        })
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files
        .map(
          (f) => StatusItem(
            filePath: f.path,
            modifiedAt: f.lastModifiedSync(),
            type: p.extension(f.path).toLowerCase() == '.mp4' ? StatusType.video : StatusType.image,
          ),
        )
        .toList();
  }

  @override
  Future<bool> saveToAppFolder(String sourcePath) async {
    try {
      final src = File(sourcePath);
      if (!await src.exists()) return false;
      final dir = await _getAppSavedDir();
      final fileName = p.basename(sourcePath);
      final destPath = p.join(dir.path, fileName);
      await src.copy(destPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> saveToGallery(String sourcePath) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return false;
      final isVideo = p.extension(sourcePath).toLowerCase() == '.mp4';
      const channel = MethodChannel('com.statussaver.gallery');
      final ok = await channel.invokeMethod<bool>('saveFile', {
        'path': sourcePath,
        'isVideo': isVideo,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}


