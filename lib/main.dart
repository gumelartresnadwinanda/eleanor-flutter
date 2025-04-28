import 'package:eleanor/core/providers/form_controller_provider.dart';
import 'package:eleanor/features/groceries/providers/grocery_list_provider.dart';
import 'package:eleanor/features/groceries/providers/ingredients_provider.dart';
import 'package:eleanor/features/groceries/providers/meal_plan_provider.dart';
import 'package:eleanor/features/groceries/providers/recipes_provider.dart';
import 'package:eleanor/features/groceries/screens/groceries_screen.dart';
import 'package:eleanor/features/groceries/screens/ingredients_screen.dart';
import 'package:eleanor/features/groceries/screens/meal_plan_detail_screen.dart';
import 'package:eleanor/features/groceries/screens/meal_plan_form_screen.dart';
import 'package:eleanor/features/groceries/screens/meal_plans_screen.dart';
import 'package:eleanor/features/groceries/screens/recipes_screen.dart';
import 'package:eleanor/features/media_library/providers/tag_media_library_provider.dart';
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
import 'package:eleanor/features/auth/providers/auth_provider.dart';
import 'package:eleanor/features/media_library/screens/media_tag_screen.dart';
import 'package:eleanor/features/media_library/screens/tag_list_screen.dart';
import 'package:eleanor/features/media_library/providers/tag_list_provider.dart';
import 'package:eleanor/features/settings/providers/settings_provider.dart';
import 'package:eleanor/features/settings/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MediaLibraryProvider()),
        ChangeNotifierProvider(create: (context) => TagMediaLibraryProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (context) => TagListProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => MealPlanProvider()),
        ChangeNotifierProvider(create: (context) => IngredientsProvider()),
        ChangeNotifierProvider(create: (context) => RecipesProvider()),
        ChangeNotifierProvider(create: (context) => GroceryListProvider()),
        ChangeNotifierProvider(create: (context) => FormControllerProvider()),
      ],
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
            child: const TagListScreen(type: 'stage'),
          ),
    ),
    GoRoute(
      path: '/media-library/persons',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: const TagListScreen(type: 'person'),
          ),
    ),
    GoRoute(
      path: '/media-library/albums',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: const TagListScreen(type: 'album'),
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
      path: '/settings',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: const SettingsScreen(),
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
    GoRoute(
      path: '/media-library/tags/:tag',
      pageBuilder: (context, state) {
        final String? tag = state.pathParameters['tag'];
        if (tag == null) {
          return buildPageWithNoTransition(
            context: context,
            state: state,
            child: const Scaffold(
              body: Center(child: Text('Error: Tag missing')),
            ),
          );
        }
        return buildPageWithNoTransition(
          context: context,
          state: state,
          child: MediaTagScreen(tag: tag),
        );
      },
    ),
    GoRoute(
      path: '/media/:id/:tag',
      pageBuilder: (context, state) {
        final String? id = state.pathParameters['id'];
        final String? tag = state.pathParameters['tag'];
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
          child: MediaViewerScreen(initialMediaId: id, tag: tag),
        );
      },
    ),

    GoRoute(
      path: '/groceries',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: GroceriesScreen(),
          ),
    ),
    GoRoute(
      path: '/groceries/ingredients',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: GroceriesIngredientsScreen(),
          ),
    ),
    GoRoute(
      path: '/groceries/recipes',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: GroceriesRecipesScreen(),
          ),
    ),
    GoRoute(
      path: '/groceries/meal-plans',
      pageBuilder:
          (context, state) => buildPageWithNoTransition(
            context: context,
            state: state,
            child: GroceriesMealPlansScreen(),
          ),
    ),
    GoRoute(
      path: '/groceries/meal-plans/form/:id',
      pageBuilder: (context, state) {
        final int id = int.parse(state.pathParameters['id']!);
        return buildPageWithNoTransition(
          context: context,
          state: state,
          child: MealPlanFormScreen(id: id),
        );
      },
    ),
    GoRoute(
      path: '/groceries/meal-plans/:id',
      pageBuilder: (context, state) {
        final int id = int.parse(state.pathParameters['id']!);
        return buildPageWithNoTransition(
          context: context,
          state: state,
          child: MealPlanDetailScreen(id: id),
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
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child,
            ),
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
      body: SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 20),
              MenuTile(
                imagePath: 'assets/food-journal.jpg',
                icon: Icons.edit_note,
                title: 'Food Journal',
                description: 'Record your meals and track nutrition',
                onTap: () {
                  context.push('/food-journal');
                },
              ),
              const SizedBox(height: 20),
              MenuTile(
                imagePath: 'assets/groceries.jpg',
                icon: Icons.shopping_cart,
                title: 'Groceries',
                description: 'Keep Track of your groceries',
                onTap: () {
                  context.push('/groceries');
                },
              ),
            ],
          ),
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
