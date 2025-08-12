import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/status_item.dart';
import '../pages/viewers/image_viewer_page.dart';
import '../pages/viewers/video_viewer_page.dart';

class MediaGrid extends StatelessWidget {
  final List<StatusItem> items;
  const MediaGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: Text('No items found')),
        ],
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final heroTag = item.filePath;
        return GestureDetector(
          onTap: () {
            if (item.type == StatusType.image) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageViewerPage(path: item.filePath, heroTag: heroTag),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoViewerPage(path: item.filePath, heroTag: heroTag),
                ),
              );
            }
          },
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.type == StatusType.image)
                    Image.file(File(item.filePath), fit: BoxFit.cover)
                  else
                    _VideoThumb(path: item.filePath),
                  if (item.type == StatusType.video)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VideoThumb extends StatefulWidget {
  final String path;
  const _VideoThumb({required this.path});

  @override
  State<_VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<_VideoThumb> {
  @override
  Widget build(BuildContext context) {
    // Lightweight placeholder; actual first-frame extraction would require init video controller which is heavy in grid.
    return Container(
      color: Colors.black12,
      child: Center(
        child: Icon(Icons.movie_creation_outlined, color: Colors.grey.shade700),
      ),
    );
  }
}


