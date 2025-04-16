import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/media_library/providers/media_library_provider.dart';
import 'package:eleanor/features/media_library/screens/media_library_screen.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:eleanor/features/media_library/screens/media_viewer_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eleanor/features/media_library/screens/media_library_home_screen.dart';
import 'package:eleanor/core/widgets/main_menu_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        return MediaLibraryProvider();
      },
      child: const MyApp(),
    ),
  );
}

CustomTransitionPage<void> buildPageWithNoTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder:
        (context, animation, secondaryAnimation, child) => child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: HomeScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaLibraryHomeScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library/all-medias',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaLibraryScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library/stages',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaStagesScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library/persons',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaPersonsScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library/albums',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaAlbumsScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library/photos',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaPhotoScreen(),
          ),
    ),
    GoRoute(
      path: '/media-library/videos',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: MediaVideoScreen(),
          ),
    ),
    GoRoute(
      path: '/food-journal',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: FoodJournalScreen(),
          ),
    ),
    GoRoute(
      path: '/media/:id',
      pageBuilder: (context, state) {
        final String? id = state.pathParameters['id'];
        if (id == null) {
          return buildPageWithNoTransition(
            context: context,
            state: state,
            child: const Scaffold(
              body: Center(child: Text('Error: Media ID missing')),
            ),
          );
        }
        return buildPageWithNoTransition(
          context: context,
          state: state,
          child: MediaViewerScreen(initialMediaId: id),
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Eleanor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child,
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MenuTile(
              imagePath: 'assets/media-library.jpg',
              icon: Icons.photo_library,
              title: 'Media Library',
              description: 'Browse and manage your photos',
              onTap: () {
                context.push('/media-library');
              },
            ),
            SizedBox(height: 20),
            MenuTile(
              imagePath: 'assets/food-journal.jpg',
              icon: Icons.edit_note,
              title: 'Food Journal',
              description: 'Record your meals and track nutrition',
              onTap: () {
                context.push('/food-journal');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}

class FoodJournalScreen extends StatelessWidget {
  FoodJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Journal')),
      body: const Center(child: Text('Food Journal Coming Soon')),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}

class MediaStagesScreen extends StatelessWidget {
  MediaStagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Stages')),
      body: const Center(child: Text('Media Stages Coming Soon')),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class MediaPersonsScreen extends StatelessWidget {
  MediaPersonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Persons')),
      body: const Center(child: Text('Media Persons Coming Soon')),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class MediaAlbumsScreen extends StatelessWidget {
  MediaAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Album Journal')),
      body: const Center(child: Text('Media Album Coming Soon')),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class MediaPhotoScreen extends StatelessWidget {
  MediaPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Photo')),
      body: const Center(child: Text('Media Photo Coming Soon')),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class MediaVideoScreen extends StatelessWidget {
  MediaVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Video')),
      body: const Center(child: Text('Media Video Coming Soon')),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}
