// ignore_for_file: use_build_context_synchronously

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/media_library/providers/media_library_provider.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  String? get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';

  Future<void> init() async {
    _accessToken = await _storage.read(key: 'adam_auth');
    _userRole = await _storage.read(key: 'user_role');
    if (_accessToken != null) {
      await _verifyAuth();
    }
  }

  Future<bool> _verifyAuth() async {
    if (_accessToken == null) return false;

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['AUTH_BASE_API_URL']}/auth/me'),
        headers: {'Cookie': 'adam_auth=$_accessToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _userRole = data['user']['role'];
        await _storage.write(key: 'user_role', value: _userRole);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Auth verification failed: $e');
    }

    await logout();
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['AUTH_BASE_API_URL']}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _accessToken = data['accessToken'];
        _userRole = data['user']['role'];
        await _storage.write(key: 'adam_auth', value: _accessToken);
        await _storage.write(key: 'user_role', value: _userRole);
        await _verifyAuth();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login failed: $e');
      return false;
    }
  }

  Future<void> logout([BuildContext? context]) async {
    _isAuthenticated = false;
    _accessToken = null;
    _userRole = null;
    await _storage.delete(key: 'adam_auth');
    await _storage.delete(key: 'user_role');
    notifyListeners();

    // Refresh media library if context is provided
    if (context != null) {
      context.read<MediaLibraryProvider>().fetchMediaItems(
        isInitialLoad: true,
        context: context,
      );
    }
  }

  Map<String, String> getAuthHeaders() {
    if (_accessToken == null) return {};
    return {'Cookie': 'adam_auth=$_accessToken'};
  }
}
