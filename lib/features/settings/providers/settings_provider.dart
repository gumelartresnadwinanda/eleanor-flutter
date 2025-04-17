import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProtectiveMode { all, protectedOnly, unprotectedOnly }

class SettingsProvider with ChangeNotifier {
  ProtectiveMode _protectiveMode = ProtectiveMode.all;
  ProtectiveMode get protectiveMode => _protectiveMode;

  static const String _protectiveModeKey = 'protective_mode';

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_protectiveModeKey);
    if (mode != null) {
      _protectiveMode = ProtectiveMode.values.firstWhere(
        (e) => e.toString() == mode,
        orElse: () => ProtectiveMode.all,
      );
    }

    notifyListeners();
  }

  bool isAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  Future<void> setProtectiveMode(
    BuildContext context,
    ProtectiveMode mode,
  ) async {
    if (!isAdmin(context)) return;
    _protectiveMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_protectiveModeKey, mode.toString());
    notifyListeners();
  }

  String getProtectiveModeParam(BuildContext context) {
    if (!isAdmin(context)) return '';
    switch (_protectiveMode) {
      case ProtectiveMode.all:
        return '';
      case ProtectiveMode.protectedOnly:
        return '&is_protected=true';
      case ProtectiveMode.unprotectedOnly:
        return '&is_protected=false';
    }
  }
}
