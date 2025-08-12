import '../entities/status_item.dart';
import '../repositories/status_repository.dart';

class GetSavedItems {
  final StatusRepository repository;
  GetSavedItems(this.repository);

  Future<List<StatusItem>> call() => repository.getSavedItems();
}


