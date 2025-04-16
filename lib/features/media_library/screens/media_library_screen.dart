import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/media_library_provider.dart';
import '../widgets/media_list_widgets.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import '../models/media_item.dart';

class MediaLibraryScreen extends StatefulWidget {
  final String? tag;

  const MediaLibraryScreen({super.key, this.tag});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Add initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaLibraryProvider>().initializeData(
        context,
        tag: widget.tag,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 200 &&
        _scrollController.position.userScrollDirection !=
            ScrollDirection.reverse) {
      setState(() => _showBackToTop = true);
    } else {
      setState(() => _showBackToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleViewMode() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MediaLibraryProvider>();
      provider.toggleViewMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaLibraryProvider>(context);
    final items = mediaProvider.mediaItems;
    final viewMode = mediaProvider.viewMode;
    final fileType = mediaProvider.fileType;
    final errorMessage = mediaProvider.errorMessage;
    final isFetchingMore = mediaProvider.isFetchingMore;
    final isLoading = mediaProvider.isLoading;
    final hasNextPage = mediaProvider.hasNextPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == ViewMode.grid ? Icons.list : Icons.grid_view,
            ),
            onPressed: () {
              toggleViewMode();
            },
          ),
          IconButton(
            icon: Icon(
              fileType == FileType.all
                  ? Icons.photo_library
                  : fileType == FileType.photo
                  ? Icons.photo
                  : Icons.videocam,
            ),
            onPressed: () {
              context.read<MediaLibraryProvider>().toggleFileType(
                context,
                widget.tag,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:
            () => mediaProvider.fetchMediaItems(
              isInitialLoad: true,
              context: context,
            ),
        child: Stack(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              items.isEmpty
                  ? const Center(child: Text('No media items found.'))
                  : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!isFetchingMore &&
                          hasNextPage &&
                          scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                        mediaProvider.fetchMediaItems(context: context);
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          viewMode == ViewMode.grid
                              ? _buildGridView(context)
                              : _buildListView(context),
                          if (isFetchingMore)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                  ),
            // if (_showBackToTop)
            //   Positioned(
            //     bottom: 20,
            //     right: 20,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.black.withAlpha(60),
            //             blurRadius: 8,
            //             offset: const Offset(0, 2),
            //           ),
            //         ],
            //       ),
            //       child: FloatingActionButton(
            //         mini: true,
            //         onPressed: _scrollToTop,
            //         backgroundColor: Colors.white.withAlpha(150),
            //         elevation: 2,
            //         child: const Icon(Icons.arrow_upward),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          if (_showBackToTop)
            FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              backgroundColor: Colors.white.withAlpha(150),
              elevation: 2,
              child: const Icon(Icons.arrow_upward),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final items = context.select((MediaLibraryProvider p) => p.mediaItems);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0.5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
        childAspectRatio: 4 / 5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaGridItem(
          mediaItem: item,
          onTap: () => _navigateToViewer(context, item),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    final items = context.select((MediaLibraryProvider p) => p.mediaItems);
    return Column(
      children:
          items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: MediaListItem(
                mediaItem: item,
                onTap: () => _navigateToViewer(context, item),
              ),
            );
          }).toList(),
    );
  }

  void _navigateToViewer(BuildContext context, MediaItem item) {
    context.push('/media/${item.id}');
  }
}
