import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';

class MediaLibraryHomeScreen extends StatefulWidget {
  const MediaLibraryHomeScreen({super.key});

  @override
  State<MediaLibraryHomeScreen> createState() => _MediaLibraryHomeScreenState();
}

class _MediaLibraryHomeScreenState extends State<MediaLibraryHomeScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Center(child: _isGridView ? _buildGridView() : _buildListView()),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      padding: const EdgeInsets.all(24),
      mainAxisSpacing: 24,
      crossAxisSpacing: 0,
      children: _buildMenuItems(),
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _buildMenuItems(),
    );
  }

  List<Widget> _buildMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.photo_library,
        title: 'All Medias',
        onTap: () => context.push('/media-library/all-medias'),
      ),
      _buildMenuItem(
        icon: Icons.theater_comedy,
        title: 'Stages',
        onTap: () => context.push('/media-library/stages'),
      ),
      _buildMenuItem(
        icon: Icons.people,
        title: 'Persons',
        onTap: () => context.push('/media-library/persons'),
      ),
      _buildMenuItem(
        icon: Icons.photo_album,
        title: 'Albums',
        onTap: () => context.push('/media-library/albums'),
      ),
      _buildMenuItem(
        icon: Icons.photo,
        title: 'Photos',
        onTap: () => context.push('/media-library/photos'),
      ),
      _buildMenuItem(
        icon: Icons.videocam,
        title: 'Videos',
        onTap: () => context.push('/media-library/videos'),
      ),
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return _isGridView
        ? InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(icon, size: 20, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
        : ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[800]),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
        );
  }
}
