import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/status_item.dart';
import '../../providers/status_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PocketPage extends ConsumerWidget {
  const PocketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(whatsappStatusesProvider);
    final items = state.saved;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('جيبي (My Pocket)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('كل ما قمت بحفظه من جميع المنصات في مكان واحد.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('لا توجد عناصر محفوظة'))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _PocketTile(item: items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PocketTile extends StatelessWidget {
  final StatusItem item;
  const _PocketTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: item.type == StatusType.video
          ? Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF2A2A2A)),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.play_circle_fill, size: 32, color: Colors.white70),
                )
              ],
            )
          : Image.file(File(item.filePath), fit: BoxFit.cover),
    );
  }
}


