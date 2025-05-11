import 'package:eleanor/features/media_library/providers/tag_media_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/media_library_provider.dart';
import '../widgets/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class MediaViewerScreen extends StatefulWidget {
  final String initialMediaId;
  final String? tag;

  const MediaViewerScreen({super.key, required this.initialMediaId, this.tag});

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
    final tagProvider = context.read<TagMediaLibraryProvider>();
    if (widget.tag != null) {
      _allItems = tagProvider.tagMediaItems[widget.tag]?.mediaItems ?? [];
    } else {
      _allItems = provider.mediaItems;
    }

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
    final provider = Provider.of<MediaLibraryProvider>(context);
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

    // TODO: add new tag edit screen or modal
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
                actions: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Media'),
                              content: const Text(
                                'Are you sure to delete this media',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final nav = Navigator.of(context);
                                    provider.delete(
                                      id: currentItem?.id,
                                      withData: false,
                                    );

                                    if (_currentIndex < _allItems.length) {
                                      _allItems.removeAt(_currentIndex);
                                    }

                                    setState(() {
                                      if (_currentIndex >= _allItems.length &&
                                          _allItems.isNotEmpty) {
                                        _currentIndex = _allItems.length - 1;
                                      }
                                    });
                                    nav.pop();
                                  },
                                  child: const Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final nav = Navigator.of(context);
                                    provider.delete(
                                      id: currentItem?.id,
                                      withData: true,
                                    );
                                    if (_currentIndex < _allItems.length) {
                                      _allItems.removeAt(_currentIndex);
                                    }

                                    setState(() {
                                      if (_currentIndex >= _allItems.length &&
                                          _allItems.isNotEmpty) {
                                        _currentIndex = _allItems.length - 1;
                                      }
                                    });
                                    nav.pop();
                                  },
                                  child: const Text(
                                    "Yes, also remove from drive",
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    tooltip: "Delete",
                  ),
                ],
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
