import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/tag_list_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';

class TagListScreen extends StatefulWidget {
  final String type;

  const TagListScreen({super.key, required this.type});

  @override
  State<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends State<TagListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialTags();
    });
  }

  void _fetchInitialTags() {
    context.read<TagListProvider>().fetchTags(
      type: widget.type,
      isInitialLoad: true,
      context: context,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 100) {
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

  Widget _buildTagCard(TagItem item) {
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
    final tagProvider = Provider.of<TagListProvider>(context);
    final items = tagProvider.tagItems;
    final errorMessage = tagProvider.errorMessage;
    final isFetchingMore = tagProvider.isFetchingMore;
    final isLoading = tagProvider.isLoading;
    final hasNextPage = tagProvider.hasNextPage;
    // TODO: Add Search Bar

    return Scaffold(
      appBar: AppBar(title: Text('${widget.type.capitalize()} Tags')),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TagListProvider>().fetchTags(
            type: widget.type,
            isInitialLoad: true,
            context: context,
          );
        },
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
                  ? const Center(child: Text('No tags found.'))
                  : SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return _buildTagCard(items[index]);
                          },
                        ),
                        if (isFetchingMore)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (hasNextPage && !isFetchingMore)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  tagProvider.fetchTags(
                                    type: widget.type,
                                    context: context,
                                  );
                                },
                                child: const Text('Load More'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
            if (_showBackToTop)
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _scrollToTop,
                      backgroundColor: Colors.white.withAlpha(150),
                      elevation: 2,
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
