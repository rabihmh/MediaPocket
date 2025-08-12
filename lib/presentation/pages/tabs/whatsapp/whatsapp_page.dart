import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/status_providers.dart';
import '../../../widgets/media_grid.dart';

class WhatsappPage extends ConsumerStatefulWidget {
  const WhatsappPage({super.key});

  @override
  ConsumerState<WhatsappPage> createState() => _WhatsappPageState();
}

class _WhatsappPageState extends ConsumerState<WhatsappPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsappStatusesProvider);
    Future<void> onRefresh() => ref.read(whatsappStatusesProvider.notifier).refreshAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp'),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: 'Images'),
          Tab(text: 'Videos'),
          Tab(text: 'Saved'),
        ]),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(onRefresh: onRefresh, child: MediaGrid(items: state.images)),
              RefreshIndicator(onRefresh: onRefresh, child: MediaGrid(items: state.videos)),
              RefreshIndicator(onRefresh: onRefresh, child: MediaGrid(items: state.saved)),
            ],
          ),
          if (state.isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (state.error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.error!)),
                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(whatsappStatusesProvider.notifier).refreshAll();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          FutureBuilder<bool>(
            future: ref.read(dataSourceProvider).hasPickedTree(),
            builder: (context, snap) {
              final show = !(snap.data ?? false) && (state.images.isEmpty && state.videos.isEmpty);
              if (!show) return const SizedBox.shrink();
              return Positioned(
                right: 16,
                bottom: 90,
                child: FilledButton.icon(
                  onPressed: () async {
                    final ds = ref.read(dataSourceProvider);
                    await ds.pickStatusesDirectoryOnce();
                    await ref.read(whatsappStatusesProvider.notifier).refreshAll();
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Pick WhatsApp Folder'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


