import '../entities/status_item.dart';
import '../repositories/status_repository.dart';

class GetWhatsappImages {
  final StatusRepository repository;
  GetWhatsappImages(this.repository);

  Future<List<StatusItem>> call() => repository.getWhatsappImages();
}

class GetWhatsappVideos {
  final StatusRepository repository;
  GetWhatsappVideos(this.repository);

  Future<List<StatusItem>> call() => repository.getWhatsappVideos();
}


