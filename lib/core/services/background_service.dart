import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/domain/entities/image_style.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';
import 'package:hadith_everyday/core/services/wallpaper_service.dart';
import 'package:hadith_everyday/data/datasources/hadith_local_datasource.dart';
import 'package:hadith_everyday/data/datasources/hadith_remote_datasource.dart';
import 'package:hadith_everyday/data/models/hadith_model.dart';
import 'package:hadith_everyday/data/repositories/hadith_repository_impl.dart';
import 'package:hadith_everyday/domain/usecases/fetch_daily_hadith.dart';
import 'package:hadith_everyday/domain/usecases/hadith_history_usecases.dart';

// ─── WorkManager Callback (MUST be a top-level function) ───────────────────────
// This runs in a separate isolate, so all dependencies must be re-initialized.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Initialize Flutter bindings for background isolate
      WidgetsFlutterBinding.ensureInitialized();

      // Load environment variables
      await dotenv.load(fileName: '.env');

      // Initialize Hive
      await Hive.initFlutter();
      if (!Hive.isBoxOpen(AppConstants.hadithBoxName)) {
        await Hive.openBox<String>(AppConstants.hadithBoxName);
      }

      // Load settings
      final prefs = await SharedPreferences.getInstance();
      final autoWallpaper =
          prefs.getBool(AppConstants.prefKeyAutoWallpaper) ?? true;
      if (!autoWallpaper) return Future.value(true); // User disabled auto

      // Retrieve used hadith IDs (within 7-day window)
      final usedIds = _getUsedIds(prefs);

      // Set up dependencies
      final localDs = HadithLocalDataSource();
      final remoteDs = HadithRemoteDataSource();
      final repo = HadithRepositoryImpl(
        remoteDataSource: remoteDs,
        localDataSource: localDs,
      );
      final fetchUseCase = FetchDailyHadithUseCase(repo);
      final saveUseCase = SaveHadithUseCase(repo);

      // Fetch a new hadith
      final (hadith, failure) = await fetchUseCase(usedIds: usedIds);
      if (failure != null || hadith == null) return Future.value(false);

      final imageStyle = ImageStyle(
        bgStyleIndex: prefs.getInt(AppConstants.prefKeyBgStyle) ?? 0,
        fontScale: prefs.getDouble(AppConstants.prefKeyFontScale) ?? 1.0,
        textAlignIndex: prefs.getInt(AppConstants.prefKeyTextAlign) ?? 0,
        bgColor1: prefs.getInt(AppConstants.prefKeyBgColor1) != null ? Color(prefs.getInt(AppConstants.prefKeyBgColor1)!) : null,
        bgColor2: prefs.getInt(AppConstants.prefKeyBgColor2) != null ? Color(prefs.getInt(AppConstants.prefKeyBgColor2)!) : null,
        textColor: prefs.getInt(AppConstants.prefKeyTextColor) != null ? Color(prefs.getInt(AppConstants.prefKeyTextColor)!) : null,
        titleColor: prefs.getInt(AppConstants.prefKeyTitleColor) != null ? Color(prefs.getInt(AppConstants.prefKeyTitleColor)!) : null,
        textPosX: prefs.getDouble('pref_text_pos_x') ?? 0.5,
        textPosY: prefs.getDouble('pref_text_pos_y') ?? 0.5,
      );

      final lang = prefs.getString(AppConstants.prefKeyLanguage) ?? AppConstants.langAr;
      final isRtl = lang == AppConstants.langAr;

      // Generate wallpaper image
      final (imagePath, imgFailure) = await HadithImageGenerator.generateAndSave(
        hadith: hadith,
        style: imageStyle,
        isRtl: isRtl,
        titleString: isRtl ? 'قال رسول الله ﷺ' : 'The Messenger of Allah ﷺ said:',
        sourceString: isRtl 
            ? 'رواه ${hadith.getLocalizedBookName(true)}' 
            : 'Narrated by ${hadith.getLocalizedBookName(false)}',
      );
      if (imgFailure != null || imagePath == null) return Future.value(false);

      // Save to local storage with image path
      final savedHadith = hadith.copyWith(imagePath: imagePath, imageStyle: imageStyle);
      await saveUseCase(savedHadith);

      // Set as wallpaper
      await WallpaperService.setWallpaper(imagePath);

      // Record this hadith ID and timestamp in shared prefs
      _recordUsedId(prefs, hadith.id);

      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}

// ─── Public Service API ────────────────────────────────────────────────────────

class BackgroundService {
  BackgroundService._();

  /// Initialize WorkManager and register the periodic task.
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Register (or re-register) the periodic hadith task.
  /// [intervalMinutes] must be >= 15 (Android WorkManager minimum).
  static Future<void> scheduleTask(int intervalMinutes) async {
    // Cancel any existing task first
    await cancelTask();

    // Android WorkManager minimum is 15 minutes
    final clampedMinutes = intervalMinutes.clamp(15, AppConstants.intervalOneWeek);

    await Workmanager().registerPeriodicTask(
      AppConstants.dailyTaskName,
      AppConstants.dailyTaskName,
      tag: AppConstants.dailyTaskTag,
      frequency: Duration(minutes: clampedMinutes),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  /// Cancel the periodic task (used when auto-wallpaper is disabled).
  static Future<void> cancelTask() async {
    await Workmanager().cancelByUniqueName(AppConstants.dailyTaskName);
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Read stored used hadith IDs, filtering out entries older than 7 days.
List<int> _getUsedIds(SharedPreferences prefs) {
  final raw = prefs.getStringList(AppConstants.prefKeyUsedHadithIds) ?? [];
  final cutoff = DateTime.now().subtract(const Duration(days: AppConstants.hadithMemoryDays));

  // Format stored: "id:isoDate"
  final valid = raw.where((entry) {
    final parts = entry.split(':');
    if (parts.length < 2) return false;
    final date = DateTime.tryParse(parts[1]);
    return date != null && date.isAfter(cutoff);
  }).toList();

  // Update prefs to only keep valid entries
  prefs.setStringList(AppConstants.prefKeyUsedHadithIds, valid);

  return valid
      .map((e) => int.tryParse(e.split(':').first) ?? -1)
      .where((id) => id != -1)
      .toList();
}

/// Record a newly shown hadith ID with today's timestamp.
void _recordUsedId(SharedPreferences prefs, int id) {
  final raw = prefs.getStringList(AppConstants.prefKeyUsedHadithIds) ?? [];
  raw.add('$id:${DateTime.now().toIso8601String()}');
  prefs.setStringList(AppConstants.prefKeyUsedHadithIds, raw);
}
