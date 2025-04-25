import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Media Library',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Food Journal',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Groceries',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        final String currentLocation = GoRouterState.of(context).uri.toString();
        String targetLocation;

        switch (index) {
          case 0:
            targetLocation = '/';
          case 1:
            targetLocation = '/media-library';
          case 2:
            targetLocation = '/food-journal';
          case 3:
            targetLocation = '/groceries';
          case 4:
            targetLocation = '/settings';
          default:
            targetLocation = '/';
        }

        if (currentLocation != targetLocation) {
          context.go(targetLocation);
        }
      },
    );
  }
}
