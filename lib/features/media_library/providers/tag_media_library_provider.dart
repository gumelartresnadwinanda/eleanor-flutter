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

enum SortOrder { asc, desc }

class MediaTag {
  List<MediaItem> _mediaItems = []; // Private field
  int _currentPage = 1; // Private field
  bool _hasNextPage = true; // Private field
  bool _isFetchingMore = false; // Private field

  List<MediaItem> get mediaItems => _mediaItems;
  set smediaItems(List<MediaItem> items) {
    _mediaItems = items;
  }

  int get currentPage => _currentPage;
  set scurrentPage(int page) {
    _currentPage = page;
  }

  bool get hasNextPage => _hasNextPage;
  set shasNextPage(bool value) {
    _hasNextPage = value;
  }

  bool get isFetchingMore => _isFetchingMore;
  set sisFetchingMore(bool value) {
    _isFetchingMore = value;
  }

  MediaTag({
    required List<MediaItem> mediaItems,
    required int currentPage,
    required bool hasNextPage,
    required bool isFetchingMore,
  }) : _mediaItems = mediaItems,
       _currentPage = currentPage,
       _hasNextPage = hasNextPage,
       _isFetchingMore = isFetchingMore;

  @override
  String toString() {
    return "Media(medias:${_mediaItems.length}, currentPage: $currentPage, hasNextPage:$hasNextPage, isFetchingMore: $isFetchingMore)";
  }
}

class TagMediaLibraryProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, MediaTag> _tagMediaItems = {};
  Map<String, MediaTag> get tagMediaItems => Map.unmodifiable(_tagMediaItems);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ViewMode _viewMode = ViewMode.grid;
  ViewMode get viewMode => _viewMode;

  FileType _fileType = FileType.all;
  FileType get fileType => _fileType;

  SortOrder _order = SortOrder.desc;
  SortOrder get order => _order;

  TagMediaLibraryProvider() {
    _isLoading = false;
    _errorMessage = null;
    _viewMode = ViewMode.grid;
    _fileType = FileType.all;
    _tagMediaItems = {};
  }

  void initializeData(BuildContext context, String tag) {
    if (_tagMediaItems[tag] != null) {
      if (_tagMediaItems[tag]!.mediaItems.isEmpty || !_isLoading) {
        fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
      }
    } else {
      initMediaTag(tag);
      fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
    }
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    notifyListeners();
  }

  void toggleSortMode(BuildContext context, String tag) {
    _order = _order == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    if (_tagMediaItems[tag] == null) initMediaTag(tag);
    _tagMediaItems[tag]!.scurrentPage = 1;
    _tagMediaItems[tag]!.shasNextPage = true;
    _tagMediaItems[tag]!.smediaItems = [];
    notifyListeners();
    fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
  }

  void initMediaTag(String tag) {
    _tagMediaItems[tag] = MediaTag(
      mediaItems: [],
      currentPage: 1,
      hasNextPage: true,
      isFetchingMore: false,
    );
  }

  void toggleFileType(BuildContext context, String tag) {
    if (_fileType == FileType.all) {
      _fileType = FileType.photo;
    } else if (_fileType == FileType.photo) {
      _fileType = FileType.video;
    } else {
      _fileType = FileType.all;
    }

    if (_tagMediaItems[tag] == null) initMediaTag(tag);
    _tagMediaItems[tag]!.scurrentPage = 1;
    _tagMediaItems[tag]!.shasNextPage = true;
    _tagMediaItems[tag]!.smediaItems = [];
    notifyListeners();
    fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
  }

  Future<void> refreshItems(BuildContext context, String tag) async {
    if (_tagMediaItems[tag] == null) initMediaTag(tag);
    _tagMediaItems[tag]!.scurrentPage = 1;
    _tagMediaItems[tag]!.shasNextPage = true;
    _tagMediaItems[tag]!.smediaItems = [];
    notifyListeners();
    await fetchMediaItems(isInitialLoad: true, context: context, tag: tag);
  }

  static const int pageSize = 50;

  Future<void> fetchMediaItems({
    bool isInitialLoad = false,
    required BuildContext context,
    String tag = 'negi',
  }) async {
    if (_tagMediaItems[tag] == null) initMediaTag(tag);
    if (_isLoading ||
        _tagMediaItems[tag]!.isFetchingMore ||
        (!isInitialLoad && !_tagMediaItems[tag]!._hasNextPage)) {
      return;
    }

    final String? baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      _errorMessage = 'API configuration is missing';
      _tagMediaItems[tag]!.smediaItems = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (isInitialLoad) {
      _tagMediaItems[tag]!.scurrentPage = 1;
      _errorMessage = null;
      _isLoading = true;
      _tagMediaItems[tag]!.smediaItems = [];
    } else {
      _tagMediaItems[tag]!.sisFetchingMore = true;
    }
    notifyListeners();

    String tagParam = '&tags=$tag';
    final settingsProvider = context.read<SettingsProvider>();
    final protectiveModeParam = settingsProvider.getProtectiveModeParam(
      context,
    );
    print('Protective Mode Param: $protectiveModeParam');
    final String apiUrl =
        '$baseUrl/medias?page=${_tagMediaItems[tag]!.currentPage}&limit=$pageSize&sort_order=${order.name}&file_type=${_fileType.name}$tagParam$protectiveModeParam';
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
            _tagMediaItems[tag]!.smediaItems = newItems;
          } else {
            _tagMediaItems[tag]!.mediaItems.addAll(newItems);
          }

          final dynamic nextValue = decodedBody['next'];
          _tagMediaItems[tag]!.shasNextPage =
              nextValue != null && nextValue.toString().isNotEmpty;

          if (_tagMediaItems[tag]!.hasNextPage) {
            _tagMediaItems[tag]!.scurrentPage =
                _tagMediaItems[tag]!.currentPage + 1;
          }
          _errorMessage = null;
        } else {
          developer.log(
            'API Error: Expected "data" key with a List. Body: ${response.body}',
            name: 'MediaLibraryProvider',
          );
          _errorMessage =
              'Failed to load media items. Unexpected response format.';
          _tagMediaItems[tag]!.smediaItems = [];
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication required for protected media';
        _tagMediaItems[tag]!.smediaItems = [];
      } else {
        developer.log(
          'API Error: ${response.statusCode} - ${response.body}',
          name: 'MediaLibraryProvider',
        );
        _errorMessage =
            'Failed to load media items. Status Code: ${response.statusCode}';
        _tagMediaItems[tag]!.smediaItems = [];
      }
    } catch (e) {
      developer.log(
        'Network/Fetch Error: $e',
        name: 'MediaLibraryProvider',
        error: e,
      );
      _errorMessage = 'Failed to load media items. Check network connection.';
      _tagMediaItems[tag]!.smediaItems = [];
    } finally {
      if (isInitialLoad) _isLoading = false;
      _tagMediaItems[tag]!.sisFetchingMore = false;
      notifyListeners();
    }
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
