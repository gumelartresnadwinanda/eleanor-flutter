import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/auth/providers/auth_provider.dart';

class TagItem {
  final String name;
  final String type;
  final String? lastMedia;

  TagItem({required this.name, required this.type, this.lastMedia});

  factory TagItem.fromJson(Map<String, dynamic> json) {
    return TagItem(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      lastMedia: json['last_media']?.toString(),
    );
  }
}

class TagListProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TagItem> _tagItems = [];
  List<TagItem> get tagItems => List.unmodifiable(_tagItems);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasNextPage = false;
  bool get hasNextPage => _hasNextPage;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  List<TagItem> _recommendations = [];
  List<TagItem> get recommendations => List.unmodifiable(_recommendations);

  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  String? _recommendationError;
  String? get recommendationError => _recommendationError;

  Future<void> fetchTags({
    required String type,
    bool isInitialLoad = false,
    required BuildContext context,
  }) async {
    if (_isLoading || _isFetchingMore || (!isInitialLoad && !_hasNextPage)) {
      return;
    }
    if (isInitialLoad) {
      _currentPage = 1;
      _errorMessage = null;
      _isLoading = true;
      _tagItems = [];
    } else {
      _isFetchingMore = true;
    }
    notifyListeners();

    final String? baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      _errorMessage = 'API configuration is missing';
      _tagItems = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    final String apiUrl =
        '$baseUrl/tags?page=$_currentPage&limit=100&sort_order=asc&sort_by=name&check_media=true&type=$type';

    try {
      final authProvider = context.read<AuthProvider>();
      final headers = authProvider.getAuthHeaders();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> itemsList = decodedBody['data'] as List;
          List<TagItem> newItems =
              itemsList.map((jsonItem) => TagItem.fromJson(jsonItem)).toList();

          if (isInitialLoad) {
            _tagItems = newItems;
          } else {
            _tagItems.addAll(newItems);
          }

          final dynamic countTag = int.parse(decodedBody['count']);
          _hasNextPage = _tagItems.length < countTag;
          if (_hasNextPage) {
            _currentPage++;
          }
          _errorMessage = null;
        } else {
          _errorMessage = 'Failed to load tags. Unexpected response format.';
          _tagItems = [];
        }
      } else {
        _errorMessage =
            'Failed to load tags. Status Code: ${response.statusCode}';
        _tagItems = [];
      }
    } catch (e) {
      developer.log('Error fetching tags: $e', error: e);
      _errorMessage = 'Failed to load tags. Check network connection.';
      _tagItems = [];
    } finally {
      if (isInitialLoad) _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations(
    String tag, {
    required BuildContext context,
  }) async {
    _isLoadingRecommendations = true;
    _recommendationError = null;
    notifyListeners();

    try {
      final String? baseUrl = dotenv.env['API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API configuration is missing');
      }

      final authProvider = context.read<AuthProvider>();
      final headers = authProvider.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/tags/recommendations/$tag'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> data = decodedBody['data'] as List;
          _recommendations =
              data.map((item) => TagItem.fromJson(item)).toList();
          _recommendationError = null;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print("error: $e");
      developer.log('Error fetching recommendations: $e', error: e);
      _recommendationError = 'Failed to load recommendations: $e';
      _recommendationError = e.toString();
      _recommendations = [];
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }
}
