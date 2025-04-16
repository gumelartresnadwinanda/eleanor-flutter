import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/auth/providers/auth_provider.dart';
import 'package:eleanor/features/auth/screens/login_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
        BottomNavigationBarItem(
          icon: Icon(authProvider.isAuthenticated ? Icons.logout : Icons.login),
          label: authProvider.isAuthenticated ? 'Logout' : 'Login',
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
            if (authProvider.isAuthenticated) {
              authProvider.logout(context);
              return;
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              return;
            }
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
