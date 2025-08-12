import '../entities/status_item.dart';

abstract class StatusRepository {
  Future<List<StatusItem>> getWhatsappImages();
  Future<List<StatusItem>> getWhatsappVideos();
  Future<List<StatusItem>> getSavedItems();
  Future<bool> saveToAppFolder(String sourcePath);
  Future<bool> saveToGallery(String sourcePath);
}


