import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/whatsapp_status_data_source.dart';
import '../../data/repositories/status_repository_impl.dart';
import '../../domain/entities/status_item.dart';
import '../../domain/repositories/status_repository.dart';
import '../../domain/usecases/get_saved_statuses.dart';
import '../../domain/usecases/get_whatsapp_statuses.dart';
import '../../data/services/storage_permission_service.dart';

final dataSourceProvider = Provider((ref) => WhatsappStatusDataSource());
final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  return StatusRepositoryImpl(ref.watch(dataSourceProvider));
});

final storagePermissionServiceProvider = Provider((ref) => StoragePermissionService());

class WhatsappStatusesState {
  final bool isLoading;
  final List<StatusItem> images;
  final List<StatusItem> videos;
  final List<StatusItem> saved;
  final String? error;

  const WhatsappStatusesState({
    required this.isLoading,
    required this.images,
    required this.videos,
    required this.saved,
    this.error,
  });

  WhatsappStatusesState copyWith({
    bool? isLoading,
    List<StatusItem>? images,
    List<StatusItem>? videos,
    List<StatusItem>? saved,
    String? error,
  }) => WhatsappStatusesState(
        isLoading: isLoading ?? this.isLoading,
        images: images ?? this.images,
        videos: videos ?? this.videos,
        saved: saved ?? this.saved,
        error: error,
      );

  factory WhatsappStatusesState.initial() => const WhatsappStatusesState(
        isLoading: false,
        images: [],
        videos: [],
        saved: [],
      );
}

class WhatsappStatusesNotifier extends StateNotifier<WhatsappStatusesState> {
  final Ref ref;
  WhatsappStatusesNotifier(this.ref) : super(WhatsappStatusesState.initial());

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(statusRepositoryProvider);
      final ds = ref.read(dataSourceProvider);

      // First attempt: MediaStore (no dialog on most devices)
      var images = await GetWhatsappImages(repo).call();
      var videos = await GetWhatsappVideos(repo).call();
      var saved = await GetSavedItems(repo).call();

      // If empty, request permissions and retry (fallback to direct FS)
      if (images.isEmpty && videos.isEmpty) {
        await ref.read(storagePermissionServiceProvider).ensureStoragePermission();
        await Future.delayed(const Duration(milliseconds: 150));
        images = await GetWhatsappImages(repo).call();
        videos = await GetWhatsappVideos(repo).call();
        if (images.isEmpty && videos.isEmpty) {
          // If we already have a persisted tree, use it silently
          final already = await ds.hasPickedTree();
          var ok = already;
          if (!already) {
            // Ask user to pick the WhatsApp folder via SAF (one-time)
            ok = await ds.pickStatusesDirectoryOnce();
          }
          if (ok) {
            final imgFiles = await ds.listFromPickedTreeImages();
            final vidFiles = await ds.listFromPickedTreeVideos();
            images = imgFiles
                .map((f) => StatusItem(
                      filePath: f.path,
                      modifiedAt: f.lastModifiedSync(),
                      type: StatusType.image,
                    ))
                .toList();
            videos = vidFiles
                .map((f) => StatusItem(
                      filePath: f.path,
                      modifiedAt: f.lastModifiedSync(),
                      type: StatusType.video,
                    ))
                .toList();
          }
        }
        saved = await GetSavedItems(repo).call();
      }

      state = state.copyWith(isLoading: false, images: images, videos: videos, saved: saved);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveToAppFolder(String path) async {
    final repo = ref.read(statusRepositoryProvider);
    final ok = await repo.saveToAppFolder(path);
    if (ok) {
      final saved = await GetSavedItems(repo).call();
      state = state.copyWith(saved: saved);
    }
    return ok;
  }
}

final whatsappStatusesProvider = StateNotifierProvider<WhatsappStatusesNotifier, WhatsappStatusesState>((ref) {
  final notifier = WhatsappStatusesNotifier(ref);
  notifier.refreshAll();
  return notifier;
});


