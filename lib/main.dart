import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/media_library/providers/media_library_provider.dart';
import 'package:eleanor/features/media_library/screens/media_library_screen.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:eleanor/features/media_library/screens/media_viewer_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => buildPageWithNoTransition(
        context: context,
        state: state,
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/media-library',
      pageBuilder: (context, state) => buildPageWithNoTransition(
        context: context,
        state: state,
        child: MediaLibraryScreen(),
      ),
    ),
    GoRoute(
      path: '/food-journal',
      pageBuilder: (context, state) => buildPageWithNoTransition(
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
                  body: Center(child: Text('Error: Media ID missing'))));
        }
        return buildPageWithNoTransition(
          context: context,
          state: state,
          child: MediaViewerScreen(
            initialMediaId: id,
          ),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
      appBar: AppBar(
        title: const Text('Eleanor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
              onPressed: () => context.go('/media-library'),
              child: const Text('Media Library'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
              onPressed: () => context.go('/food-journal'),
              child: const Text('Food Journal'),
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
      appBar: AppBar(
        title: const Text('Food Journal'),
      ),
      body: const Center(
        child: Text('Food Journal Coming Soon'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
