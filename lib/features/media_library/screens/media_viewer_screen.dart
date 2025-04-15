import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/media_library_provider.dart';

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
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(currentItem?.title ?? 'Media Viewer'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _allItems.length,
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
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child:
                  item.fileType == MediaType.video
                      ? _buildVideoPlayer(item)
                      : Image.network(
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
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer(MediaItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, color: Colors.grey, size: 50),
          const SizedBox(height: 10),
          Text(
            'Video Player for\n${item.title}\nComing Soon',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
