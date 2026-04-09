import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/app/app.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/services/background_service.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';

Future<void> main() async {
  // ── Flutter binding ────────────────────────────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── System UI ─────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Environment variables ──────────────────────────────────────────────────
  // .env is bundled as an asset (see pubspec.yaml)
  await dotenv.load(fileName: '.env');

  // ── Hive local database ────────────────────────────────────────────────────
  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.hadithBoxName);

  // ── SharedPreferences ──────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  // ── WorkManager background tasks ───────────────────────────────────────────
  await BackgroundService.initialize();

  // Restore scheduled task if auto-wallpaper is still enabled
  final autoWallpaper = prefs.getBool(AppConstants.prefKeyAutoWallpaper) ?? true;
  final intervalMinutes =
      prefs.getInt(AppConstants.prefKeyIntervalMinutes) ??
          AppConstants.defaultIntervalMinutes;
  if (autoWallpaper) {
    await BackgroundService.scheduleTask(intervalMinutes);
  }

  // ── Run app ───────────────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        // Inject the already-initialized SharedPreferences instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const HadithApp(),
    ),
  );
}
