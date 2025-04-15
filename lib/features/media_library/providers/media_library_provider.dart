import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart  ' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ViewMode { grid, list }

class MediaLibraryProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<MediaItem> _mediaItems = [];
  List<MediaItem> get mediaItems => List.unmodifiable(_mediaItems);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ViewMode _viewMode = ViewMode.grid;
  ViewMode get viewMode => _viewMode;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  bool _hasNextPage = true;
  bool get hasNextPage => _hasNextPage;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  MediaLibraryProvider() {
    fetchMediaItems(isInitialLoad: true);
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    notifyListeners();
  }

  Future<void> fetchMediaItems({bool isInitialLoad = false}) async {
    final String? baseUrl = dotenv.env['API_BASE_URL'];
    if (_isLoading || _isFetchingMore || (!isInitialLoad && !_hasNextPage)) {
      return;
    }
    if (isInitialLoad) {
      _currentPage = 1;
      _errorMessage = null;
      _isLoading = true;
    } else {
      _isFetchingMore = true;
    }
    notifyListeners();

    if (baseUrl == null) {
      _errorMessage = 'API configuration is missing';
      _mediaItems = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    final String apiUrl =
        '$baseUrl/medias?page=$_currentPage&limit=100&sort_order=desc&file_type=photo';
    developer.log(
      'Fetching media items from: $apiUrl',
      name: 'MediaLibraryProvider',
    );
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> itemsList = decodedBody['data'] as List;
          List<MediaItem> newItems =
              itemsList
                  .map((jsonItem) {
                    try {
                      if (jsonItem is Map<String, dynamic>) {
                        return MediaItem.fromJson(jsonItem);
                      } else {
                        developer.log(
                          'Skipping non-map item in list: $jsonItem',
                          name: 'MediaLibraryProvider',
                        );
                        return null;
                      }
                    } catch (e) {
                      developer.log(
                        'Error parsing item: $jsonItem',
                        name: 'MediaLibraryProvider',
                        error: e,
                      );
                      return null;
                    }
                  })
                  .whereType<MediaItem>()
                  .toList();

          if (isInitialLoad) {
            _mediaItems = newItems;
          } else {
            _mediaItems.addAll(newItems);
          }

          final dynamic nextValue = decodedBody['next'];
          _hasNextPage = nextValue != null && nextValue.toString().isNotEmpty;

          if (_hasNextPage) {
            _currentPage++;
          }
          _errorMessage = null;
        } else {
          developer.log(
            'API Error: Expected "data" key with a List. Body: ${response.body}',
            name: 'MediaLibraryProvider',
          );
          _errorMessage =
              'Failed to load media items. Unexpected response format.';
          _mediaItems = [];
        }
      } else {
        developer.log(
          'API Error: ${response.statusCode} - ${response.body}',
          name: 'MediaLibraryProvider',
        );
        _errorMessage =
            'Failed to load media items. Status Code: ${response.statusCode}';
        _mediaItems = [];
      }
    } catch (e) {
      developer.log(
        'Network/Fetch Error: $e',
        name: 'MediaLibraryProvider',
        error: e,
      );
      _errorMessage = 'Failed to load media items. Check network connection.';
      _mediaItems = []; // Clear items on fetch error
    } finally {
      if (isInitialLoad) _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreMediaItems() async {
    await fetchMediaItems();
  }
}
