import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/media_library_provider.dart';
import '../widgets/media_list_widgets.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import '../models/media_item.dart';
import '../widgets/media_grid_widget.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaLibraryProvider>().fetchMediaItems(
        isInitialLoad: true,
        context: context,
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

    final mediaProvider = context.read<MediaLibraryProvider>();
    if (!mediaProvider.isFetchingMore &&
        mediaProvider.hasNextPage &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      mediaProvider.fetchMediaItems(context: context);
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
    final isLoading = mediaProvider.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == ViewMode.grid ? Icons.list : Icons.grid_view,
            ),
            onPressed: toggleViewMode,
            tooltip: viewMode == ViewMode.grid ? "List" : "Grid",
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
            tooltip:
                fileType == FileType.all
                    ? "All Media Type"
                    : fileType == FileType.photo
                    ? "Photo Only"
                    : "Video Only",
          ),
          // TODO: Add modal to set sorting field and sorting direction
          IconButton(
            icon: Icon(
              context.select((MediaLibraryProvider p) => p.order) ==
                      SortOrder.asc
                  ? Icons.north
                  : Icons.south,
            ),
            onPressed: () {
              context.read<MediaLibraryProvider>().toggleSortMode(
                context,
                widget.tag,
              );
            },
            tooltip:
                context.select((MediaLibraryProvider p) => p.order) ==
                        SortOrder.asc
                    ? "Oldest First"
                    : "Latest First",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MediaLibraryProvider>().refreshItems(
            context,
            widget.tag,
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else if (items.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No media items found.')),
              )
            else if (viewMode == ViewMode.grid)
              _buildGridView(context, items)
            else
              _buildListView(context, items),
            if (mediaProvider.isFetchingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton:
          _showBackToTop
              ? FloatingActionButton(
                mini: true,
                onPressed: _scrollToTop,
                backgroundColor: Colors.white.withAlpha(150),
                elevation: 2,
                child: const Icon(Icons.arrow_upward),
              )
              : null,
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildGridView(BuildContext context, List<MediaItem> items) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        return CachedMediaGridItem(
          mediaItem: item,
          onTap: () => _navigateToViewer(context, item),
        );
      }, childCount: items.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
        childAspectRatio: 4 / 5,
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<MediaItem> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: MediaListItem(
            mediaItem: item,
            onTap: () => _navigateToViewer(context, item),
          ),
        );
      }, childCount: items.length),
    );
  }

  void _navigateToViewer(BuildContext context, MediaItem item) {
    context.push('/media/${item.id}');
  }
}
