import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eleanor/features/auth/providers/auth_provider.dart';
import 'package:eleanor/features/settings/providers/settings_provider.dart';

enum ViewMode { grid, list }

enum FileType { all, photo, video }

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

  FileType _fileType = FileType.all;
  FileType get fileType => _fileType;

  MediaLibraryProvider() {
    _isLoading = false;
    _mediaItems = [];
    _errorMessage = null;
    _viewMode = ViewMode.grid;
    _currentPage = 1;
    _hasNextPage = true;
    _isFetchingMore = false;
    _fileType = FileType.all;
  }

  void initializeData(BuildContext context, {String? tag}) {
    if (_mediaItems.isEmpty || !_isLoading) {
      fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
    }
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
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
    notifyListeners();
    fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
  }

  Future<void> refreshItems(BuildContext context, String? tag) async {
    _currentPage = 1;
    _hasNextPage = true;
    _mediaItems = [];
    notifyListeners();
    await fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
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
    final settingsProvider = context.read<SettingsProvider>();
    final protectiveModeParam = settingsProvider.getProtectiveModeParam(
      context,
    );
    print('Protective Mode Param: $protectiveModeParam');
    final String apiUrl =
        '$baseUrl/medias?page=$_currentPage&limit=$pageSize&sort_order=desc&file_type=${_fileType.name}$tagParam$protectiveModeParam';
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
