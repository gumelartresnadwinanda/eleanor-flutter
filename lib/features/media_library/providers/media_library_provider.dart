import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ViewMode { grid, list }

enum FileType { all, photo, video }

class MediaLibraryProvider with ChangeNotifier {
  static const String _viewModeKey = 'media_library_view_mode';
  static const String _fileTypeKey = 'media_library_file_type';
  static const String _mediaItemsKey = 'media_library_items';
  static const String _currentPageKey = 'media_library_current_page';
  static const String _hasNextPageKey = 'media_library_has_next_page';
  static const String _currentTagKey = 'media_library_current_tag';

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

  FileType _fileType = FileType.all;
  FileType get fileType => _fileType;

  bool _shouldRefresh = true;
  String? _currentTag;

  MediaLibraryProvider() {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load view mode
    final viewModeIndex = prefs.getInt(_viewModeKey);
    if (viewModeIndex != null) {
      _viewMode = ViewMode.values[viewModeIndex];
    }

    // Load file type
    final fileTypeIndex = prefs.getInt(_fileTypeKey);
    if (fileTypeIndex != null) {
      _fileType = FileType.values[fileTypeIndex];
    }

    // Load current page
    _currentPage = prefs.getInt(_currentPageKey) ?? 1;

    // Load has next page
    _hasNextPage = prefs.getBool(_hasNextPageKey) ?? true;

    // Load current tag
    _currentTag = prefs.getString(_currentTagKey);

    // Load media items
    final mediaItemsJson = prefs.getString(_mediaItemsKey);
    if (mediaItemsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(mediaItemsJson);
        _mediaItems = decoded.map((item) => MediaItem.fromJson(item)).toList();
      } catch (e) {
        developer.log('Error loading persisted media items: $e');
        _mediaItems = [];
      }
    }

    notifyListeners();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_viewModeKey, _viewMode.index);
    await prefs.setInt(_fileTypeKey, _fileType.index);
    await prefs.setInt(_currentPageKey, _currentPage);
    await prefs.setBool(_hasNextPageKey, _hasNextPage);
    await prefs.setString(_currentTagKey, _currentTag ?? '');

    if (_mediaItems.isNotEmpty) {
      final mediaItemsJson = json.encode(
        _mediaItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_mediaItemsKey, mediaItemsJson);
    }
  }

  void initializeData(BuildContext context, {String? tag}) {
    if (_shouldRefresh || tag != _currentTag) {
      _currentTag = tag;
      _shouldRefresh = false;
      fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
    }
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    _persistState();
    notifyListeners();
  }

  void toggleFileType(BuildContext context, String? tag) {
    if (_fileType == FileType.all) {
      _fileType = FileType.photo;
    } else if (_fileType == FileType.photo) {
      _fileType = FileType.video;
    } else {
      _fileType = FileType.all;
    }
    _currentPage = 1;
    _hasNextPage = true;
    _mediaItems = [];
    _shouldRefresh = true;
    _persistState();
    notifyListeners();
    fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
  }

  void refreshItems(BuildContext context, String? tag) {
    _currentPage = 1;
    _hasNextPage = true;
    _mediaItems = [];
    _shouldRefresh = true;
    _persistState();
    notifyListeners();
    fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
  }

  static const int pageSize = 30;

  Future<void> fetchMediaItems({
    bool isInitialLoad = false,
    required BuildContext context,
    String? tag,
  }) async {
    if (_isLoading || _isFetchingMore || (!isInitialLoad && !_hasNextPage)) {
      return;
    }

    final String? baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      _errorMessage = 'API configuration is missing';
      _mediaItems = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (isInitialLoad) {
      _currentPage = 1;
      _errorMessage = null;
      _isLoading = true;
      _mediaItems = [];
    } else {
      _isFetchingMore = true;
    }
    notifyListeners();

    String tagParam = tag != null ? '&tags=$tag' : '';
    final String apiUrl =
        '$baseUrl/medias?page=$_currentPage&limit=$pageSize&sort_order=desc&file_type=${_fileType.name}$tagParam';
    developer.log(
      'Fetching media items from: $apiUrl',
      name: 'MediaLibraryProvider',
    );
    try {
      final authProvider = context.read<AuthProvider>();
      final headers = authProvider.getAuthHeaders();

      final response = await http.get(Uri.parse(apiUrl), headers: headers);

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

          // Persist the updated state
          await _persistState();
        } else {
          developer.log(
            'API Error: Expected "data" key with a List. Body: ${response.body}',
            name: 'MediaLibraryProvider',
          );
          _errorMessage =
              'Failed to load media items. Unexpected response format.';
          _mediaItems = [];
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication required for protected media';
        _mediaItems = [];
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
      _mediaItems = [];
    } finally {
      if (isInitialLoad) _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreMediaItems(BuildContext context) async {
    await fetchMediaItems(context: context);
  }

  Future<String?> getMediaUrl(String mediaId, BuildContext context) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final headers = authProvider.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/media/$mediaId/url'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        throw Exception('Failed to get media URL');
      }
    } catch (e) {
      throw Exception('Error getting media URL: $e');
    }
  }
}
