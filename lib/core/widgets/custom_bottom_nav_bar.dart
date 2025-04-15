import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Media Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Food Journal',
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
          default:
            targetLocation = '/';
        }
        if (currentLocation != targetLocation) {
          context.go(targetLocation);
        }
      }
    );
  }
}
