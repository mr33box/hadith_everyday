/// App-wide constants: storage keys, intervals, Hive box names
class AppConstants {
  AppConstants._();

  // ─── Hive Box Names ────────────────────────────────────────────────────────
  static const String hadithBoxName = 'hadiths';
  static const String settingsBoxName = 'settings';

  // ─── SharedPreferences Keys ────────────────────────────────────────────────
  static const String prefKeyDarkMode = 'dark_mode';
  static const String prefKeyLanguage = 'language';
  static const String prefKeyAutoWallpaper = 'auto_wallpaper';
  static const String prefKeyIntervalMinutes = 'interval_minutes';
  static const String prefKeyBgStyle = 'bg_style';
  static const String prefKeyFontScale = 'font_scale';
  static const String prefKeyTextAlign = 'text_align';
  static const String prefKeyUsedHadithIds = 'used_hadith_ids';
  static const String prefKeyLastFetchDate = 'last_fetch_date';
  static const String prefKeyLastHadithJson = 'last_hadith_json'; // State persistence
  static const String prefKeyBgColor1 = 'bg_color1'; // Custom gradient color 1
  static const String prefKeyBgColor2 = 'bg_color2'; // Custom gradient color 2
  static const String prefKeyTextColor = 'text_color'; // Custom text color
  static const String prefKeyTitleColor = 'title_color'; // Custom title color
  static const String prefKeyFontFamily = 'font_family'; // 0=Cairo, 1=Amiri, 2=Scheherazade

  // ─── WorkManager Task ──────────────────────────────────────────────────────
  static const String dailyTaskName = 'daily_hadith_task';
  static const String dailyTaskTag = 'hadith_wallpaper';

  // ─── Wallpaper Platform Channel ────────────────────────────────────────────
  static const String wallpaperChannel = 'com.haditheveryday/wallpaper';
  static const String wallpaperMethod = 'setWallpaper';

  // ─── Update Intervals (in minutes) ────────────────────────────────────────
  static const int intervalOneHour = 60;
  static const int intervalSixHours = 360;
  static const int intervalTwelveHours = 720;
  static const int intervalOneDay = 1440;
  static const int intervalThreeDays = 4320;
  static const int intervalOneWeek = 10080;
  static const int defaultIntervalMinutes = intervalOneDay;

  /// IDs to forget after this many days (rolling window)
  static const int hadithMemoryDays = 7;

  // ─── Image Generation ─────────────────────────────────────────────────────
  static const double wallpaperWidth = 1080.0;
  static const double wallpaperHeight = 1920.0;

  // ─── Saved Images Directory Name ──────────────────────────────────────────
  static const String imagesDirName = 'hadith_wallpapers';

  // ─── Supported Locales ────────────────────────────────────────────────────
  static const String langEn = 'en';
  static const String langAr = 'ar';
}
