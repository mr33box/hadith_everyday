import 'package:flutter/services.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/errors/failures.dart';

/// Communicates with the native Android WallpaperManager via a MethodChannel.
class WallpaperService {
  static const MethodChannel _channel =
      MethodChannel(AppConstants.wallpaperChannel);

  /// Sets wallpaper on [screen]: 'home', 'lock', or 'both' (default).
  /// Returns null on success, a [WallpaperFailure] on error.
  static Future<Failure?> setWallpaper(String imagePath,
      {String screen = 'both'}) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        AppConstants.wallpaperMethod,
        {'imagePath': imagePath, 'screen': screen},
      );
      if (result == true) return null;
      return const WallpaperFailure('Failed to set wallpaper.');
    } on PlatformException catch (e) {
      return WallpaperFailure('Platform error: ${e.message}');
    } catch (e) {
      return WallpaperFailure('Unexpected error: $e');
    }
  }

  /// Check if wallpaper setting is supported on this device.
  static Future<bool> isSupported() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isWallpaperSupported');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
