import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/auth/providers/auth_provider.dart';
import 'package:eleanor/features/settings/providers/settings_provider.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:eleanor/features/auth/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showProtectiveModeDialog(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    ProtectiveMode? selectedMode = settingsProvider.protectiveMode;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Select Protective Mode'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ProtectiveMode>(
                        title: const Text('Show All Media'),
                        value: ProtectiveMode.all,
                        groupValue: selectedMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMode = value);
                          }
                        },
                      ),
                      RadioListTile<ProtectiveMode>(
                        title: const Text('Protected Only'),
                        value: ProtectiveMode.protectedOnly,
                        groupValue: selectedMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMode = value);
                          }
                        },
                      ),
                      RadioListTile<ProtectiveMode>(
                        title: const Text('Unprotected Only'),
                        value: ProtectiveMode.unprotectedOnly,
                        groupValue: selectedMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMode = value);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          selectedMode == settingsProvider.protectiveMode
                              ? null
                              : () {
                                settingsProvider.setProtectiveMode(
                                  context,
                                  selectedMode!,
                                );
                                Navigator.pop(context);
                              },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (authProvider.isAdmin) ...[
            const Text(
              'Protective Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Current Mode'),
              subtitle: Text(switch (settingsProvider.protectiveMode) {
                ProtectiveMode.all => 'Show All Media',
                ProtectiveMode.protectedOnly => 'Protected Only',
                ProtectiveMode.unprotectedOnly => 'Unprotected Only',
              }),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showProtectiveModeDialog(context),
            ),
            const Divider(),
          ],
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    authProvider.isAuthenticated
                        ? Colors.red.withAlpha(25)
                        : Colors.green.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                authProvider.isAuthenticated ? Icons.logout : Icons.login,
                color: authProvider.isAuthenticated ? Colors.red : Colors.green,
              ),
            ),
            title: Text(
              authProvider.isAuthenticated ? 'Logout' : 'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: authProvider.isAuthenticated ? Colors.red : Colors.green,
              ),
            ),
            subtitle: Text(
              authProvider.isAuthenticated
                  ? 'Tap to sign out of your account'
                  : 'Tap to sign in to your account',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    authProvider.isAuthenticated
                        ? Colors.red.withAlpha(25)
                        : Colors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                authProvider.isAuthenticated ? 'Sign Out' : 'Sign In',
                style: TextStyle(
                  color:
                      authProvider.isAuthenticated ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              if (authProvider.isAuthenticated) {
                _showLogoutConfirmation(context);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }
}
