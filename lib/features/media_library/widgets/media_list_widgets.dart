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
    const double placeholderAspectRatio = 1.0;
    final List<String> tagList =
        mediaItem.tags
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  mediaItem.listThumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return AspectRatio(
                      aspectRatio: placeholderAspectRatio,
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return AspectRatio(
                      aspectRatio: placeholderAspectRatio,
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaItem.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (tagList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children:
                                tagList.map((tag) {
                                  return GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withAlpha(20),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
