import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/media_library_provider.dart';
import '../widgets/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

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
  bool _isLoading = true;

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
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = false;
    });
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

    final List<String> tagList =
        currentItem != null
            ? currentItem.tags
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList()
            : [];

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
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _allItems.length,
              physics: _isZoomed ? const NeverScrollableScrollPhysics() : null,
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
            if (_showControls && tagList.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withAlpha(150), Colors.transparent],
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        tagList.map((tag) {
                          return GestureDetector(
                            onTap: () {
                              context.push('/media-library/tags/$tag');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
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

  Widget _buildImageCachedViewer(MediaItem item) {
    return CachedNetworkImage(
      imageUrl: item.filePath,
      fit: BoxFit.contain,
      placeholder:
          (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget:
          (context, url, error) =>
              const Center(child: Icon(Icons.broken_image)),
    );
  }
}
