import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class PermissionService {
  static Future<bool> requestImagePermission({
    required void Function(String message) onPermissionDenied,
    required void Function(String message) onPermissionPermanentlyDenied,
  }) async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        return _handlePermissionStatus(
          status,
          onPermissionDenied,
          onPermissionPermanentlyDenied,
        );
      } else if (sdkInt >= 29) {
        final status = await Permission.storage.request();
        return _handlePermissionStatus(
          status,
          onPermissionDenied,
          onPermissionPermanentlyDenied,
        );
      } else {
        final status = await Permission.storage.request();
        return _handlePermissionStatus(
          status,
          onPermissionDenied,
          onPermissionPermanentlyDenied,
        );
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return _handlePermissionStatus(
        status,
        onPermissionDenied,
        onPermissionPermanentlyDenied,
      );
    }

    return false;
  }

  static Future<bool> _handlePermissionStatus(
    PermissionStatus status,
    void Function(String message) onPermissionDenied,
    void Function(String message) onPermissionPermanentlyDenied,
  ) async {
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      onPermissionDenied('Permission to access photos was denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      onPermissionPermanentlyDenied(
        'Permission to access photos was permanently denied. Please enable it in settings.',
      );
      await openAppSettings();
      return false;
    }
    return false;
  }
}
