import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/media_library_provider.dart';
import '../widgets/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaViewerScreen extends StatefulWidget {
  final String initialMediaId;

  const MediaViewerScreen({super.key, required this.initialMediaId});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late List<MediaItem> _allItems;
  bool _showControls = false;
  bool _isZoomed = false;
  @override
  void initState() {
    super.initState();
    final provider = context.read<MediaLibraryProvider>();
    _allItems = provider.mediaItems;

    _currentIndex = _allItems.indexWhere(
      (item) => item.id == widget.initialMediaId,
    );
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }

    _pageController = PageController(initialPage: _currentIndex);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_allItems.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
          foregroundColor: Colors.white,
          title: const Text("Media Viewer"),
        ),
        body: const Center(
          child: Text(
            "No media items found.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentItem =
        _allItems.isNotEmpty && _currentIndex < _allItems.length
            ? _allItems[_currentIndex]
            : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar:
          _showControls
              ? AppBar(
                backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
                elevation: 0,
                foregroundColor: Colors.white,
                title: Text(currentItem?.title ?? 'Media Viewer'),
              )
              : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _allItems.length,
          physics: _isZoomed ? NeverScrollableScrollPhysics() : null,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = _allItems[index];
            return InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              onInteractionUpdate: (details) {
                final bool wasZoomed = _isZoomed;
                _isZoomed = details.scale > 1.0;
                print('Zoomed2: $details.scale');
                print('Was zoomed: $wasZoomed');
                if (wasZoomed != _isZoomed) {
                  setState(() {});
                }
              },
              child: Center(
                child:
                    item.fileType == MediaType.video
                        ? _buildVideoPlayer(item)
                        : _buildImageCachedViewer(item),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(MediaItem item) {
    return MediaVideoPlayer(
      videoUrl: item.filePath,
      showControls: _showControls,
      onToggleControls: _toggleControls,
    );
  }

  // ignore: unused_element
  Widget _buildImageViewer(MediaItem item) {
    return Image.network(
      item.filePath,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
        );
      },
    );
  }

  Widget _buildImageCachedViewer(MediaItem item) {
    return CachedNetworkImage(
      imageUrl: item.filePath,
      fit: BoxFit.contain,
      progressIndicatorBuilder:
          (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
      errorWidget:
          (context, url, error) => const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
          ),
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheWidth: 2000,
      memCacheHeight: 2000,
      maxWidthDiskCache: 2000,
      maxHeightDiskCache: 2000,
    );
  }
}
