import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/media_library_provider.dart';
import '../widgets/media_list_widgets.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import '../models/media_item.dart';

class MediaLibraryScreen extends StatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = context.read<MediaLibraryProvider>();
      if (!provider.isFetchingMore && provider.hasNextPage) {
        provider.fetchMoreMediaItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaLibraryProvider>(context);
    final items = mediaProvider.mediaItems;
    final viewMode = mediaProvider.viewMode;
    final errorMessage = mediaProvider.errorMessage;
    final isFetchingMore = mediaProvider.isFetchingMore;
    final isLoading = mediaProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == ViewMode.grid ? Icons.list : Icons.grid_view,
            ),
            onPressed: () {
              context.read<MediaLibraryProvider>().toggleViewMode();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : items.isEmpty
              ? const Center(child: Text('No media items found.'))
              : Column(
                children: [
                  Expanded(
                    child:
                        viewMode == ViewMode.grid
                            ? _buildGridView(context, items)
                            : _buildListView(context, items),
                  ),
                  if (isFetchingMore)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildGridView(BuildContext context, List<MediaItem> items) {
    return GridView.builder(
      controller: _scrollController,
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

  Widget _buildListView(BuildContext context, List<MediaItem> items) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: MediaListItem(
            mediaItem: item,
            onTap: () => _navigateToViewer(context, item),
          ),
        );
      },
    );
  }

  void _navigateToViewer(BuildContext context, MediaItem item) {
    context.push('/media/${item.id}');
  }
}
