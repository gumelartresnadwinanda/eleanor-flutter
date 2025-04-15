import 'package:flutter/material.dart';
import '../models/media_item.dart';

class MediaGridItem extends StatelessWidget {
  final MediaItem mediaItem;
  final VoidCallback onTap;
  const MediaGridItem({
    super.key,
    required this.mediaItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              mediaItem.gridThumbnail,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[300]);
              },
            ),
            if (mediaItem.fileType == MediaType.video)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MediaListItem extends StatelessWidget {
  final MediaItem mediaItem;
  final VoidCallback onTap;
  const MediaListItem({
    super.key,
    required this.mediaItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    mediaItem.listThumbnail,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: Colors.grey[300]);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[300]);
                    },
                  ),
                  if (mediaItem.fileType == MediaType.video)
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(mediaItem.title, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
