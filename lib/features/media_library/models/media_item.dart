import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

@immutable
class MediaItem {
  final String id;
  final String title;
  final String filePath;
  final MediaType fileType;
  final String tags;
  final DateTime date; 
  final String thumbnailPath;
  final bool isProtected;
  final String thumbnailLg;
  final String thumbnailMd;

  const MediaItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.tags,
    required this.date,
    required this.thumbnailPath,
    required this.isProtected,
    required this.thumbnailLg,
    required this.thumbnailMd,
  });

 String get gridThumbnail {
    if (thumbnailMd.isNotEmpty) {
      return thumbnailMd;
    }
    return filePath;
  }

  String get listThumbnail {
    if (thumbnailLg.isNotEmpty) {
      return thumbnailLg;
    }
    return filePath;
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final String createdAtString = json['created_at'] as String? ?? '';
      parsedDate = DateTime.parse(createdAtString);
    } catch (e) {
      developer.log('Error parsing date string: ${json['created_at']}', name: 'MediaItem.fromJson', error: e);
      parsedDate = DateTime.now();
    }

    final String fileTypeString = json['file_type'] as String? ?? 'photo';
    final MediaType parsedFileType = fileTypeString.toLowerCase() == 'video'
        ? MediaType.video
        : MediaType.photo;
    final dynamic idValue = json['id'];
    final String parsedId = idValue?.toString() ?? '';
    
    return MediaItem(
      id: parsedId,
      title: json['title'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      fileType: parsedFileType,
      tags: json['tags'] as String? ?? '',
      date: parsedDate,
      thumbnailPath: json['thumbnail_path'] as String? ?? '',
      isProtected: json['is_protected'] as bool? ?? false,
      thumbnailLg: json['thumbnail_lg'] as String? ?? '',
      thumbnailMd: json['thumbnail_md'] as String? ?? '',
    );
  }

  List<String> get tagList => tags
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  @override
  String toString() {
    return 'MediaItem(id: $id, title: $title, fileType: $fileType, date: $date, tags: "$tags")';
  }
}

enum MediaType {
  photo,
  video,
} 