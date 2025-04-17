import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/media_library_provider.dart';
import '../providers/tag_list_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../widgets/media_list_widgets.dart';
import '../models/media_item.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';

class MediaTagScreen extends StatefulWidget {
  final String tag;

  const MediaTagScreen({super.key, required this.tag});

  @override
  State<MediaTagScreen> createState() => _MediaTagScreenState();
}

class _MediaTagScreenState extends State<MediaTagScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    // Fetch media items for the tag
    context.read<MediaLibraryProvider>().fetchMediaItems(
      isInitialLoad: true,
      context: context,
      tag: widget.tag,
    );
    // Fetch recommendations for the tag
    context.read<TagListProvider>().fetchRecommendations(
      widget.tag,
      context: context,
    );
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

  Widget _buildRecommendationCard(TagItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/media-library/tags/${item.name}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.lastMedia != null)
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: item.lastMedia!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag),
        actions: [
          IconButton(
            icon: Icon(
              context.select((MediaLibraryProvider p) => p.viewMode) ==
                      ViewMode.grid
                  ? Icons.list
                  : Icons.grid_view,
            ),
            onPressed: () {
              context.read<MediaLibraryProvider>().toggleViewMode();
            },
          ),
          IconButton(
            icon: Icon(
              context.select((MediaLibraryProvider p) => p.fileType) ==
                      FileType.all
                  ? Icons.photo_library
                  : context.select((MediaLibraryProvider p) => p.fileType) ==
                      FileType.photo
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
      body: NotificationListener<ScrollNotification>(
        child: RefreshIndicator(
          onRefresh:
              () => context.read<MediaLibraryProvider>().fetchMediaItems(
                isInitialLoad: true,
                context: context,
                tag: widget.tag,
              ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildContent(context)),
              if (context.select((MediaLibraryProvider p) => p.isFetchingMore))
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
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

  Widget _buildContent(BuildContext context) {
    final isLoading = context.select((MediaLibraryProvider p) => p.isLoading);
    final errorMessage = context.select(
      (MediaLibraryProvider p) => p.errorMessage,
    );
    final items = context.select((MediaLibraryProvider p) => p.mediaItems);
    final viewMode = context.select((MediaLibraryProvider p) => p.viewMode);
    final hasNextPage = context.select(
      (MediaLibraryProvider p) => p.hasNextPage,
    );
    final isFetchingMore = context.select(
      (MediaLibraryProvider p) => p.isFetchingMore,
    );

    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(child: Text('No media items found.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewMode == ViewMode.grid)
          GridView.builder(
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
          )
        else
          ...items.map((item) {
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
          }),
        if (hasNextPage && !isFetchingMore)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<MediaLibraryProvider>().fetchMediaItems(
                  context: context,
                  tag: widget.tag,
                );
              },
              child: const Text('Load More'),
            ),
          ),
        if (isFetchingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        _buildRecommendations(context),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    final recommendations = context.select(
      (TagListProvider p) => p.recommendations,
    );
    final isLoadingRecommendations = context.select(
      (TagListProvider p) => p.isLoadingRecommendations,
    );
    final recommendationError = context.select(
      (TagListProvider p) => p.recommendationError,
    );

    if (recommendations.isEmpty &&
        !isLoadingRecommendations &&
        recommendationError == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'More Like ${widget.tag}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (isLoadingRecommendations)
          const Center(child: CircularProgressIndicator())
        else if (recommendationError != null)
          Center(
            child: Text(
              recommendationError,
              style: const TextStyle(color: Colors.red),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(recommendations[index]);
            },
          ),
      ],
    );
  }

  void _navigateToViewer(BuildContext context, MediaItem item) {
    context.push('/media/${item.id}');
  }
}
