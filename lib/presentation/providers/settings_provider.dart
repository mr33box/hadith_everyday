import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/services/background_service.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';

// ─── App Settings Model ────────────────────────────────────────────────────────

class AppSettings {
  const AppSettings({
    this.isDarkMode = false,
    this.language = AppConstants.langAr,
    this.autoWallpaper = true,
    this.intervalMinutes = AppConstants.defaultIntervalMinutes,
    this.bgStyleIndex = 0,
    this.fontScale = 1.0,
    this.textAlignIndex = 0,
    // Design customization
    this.fontFamilyIndex = 0,   // 0=Cairo, 1=Default, 2=Serif
    this.bgColor1 = const Color(0xFFF5DEB3),
    this.bgColor2 = const Color(0xFF8B5E3C),
    this.textColor = const Color(0xFF2C1A0E),
    this.titleColor = const Color(0xFF8B4513),
  });

  final bool isDarkMode;
  final String language;
  final bool autoWallpaper;
  final int intervalMinutes;
  final int bgStyleIndex;
  final double fontScale;
  final int textAlignIndex;
  final int fontFamilyIndex;
  final Color bgColor1;
  final Color bgColor2;
  final Color textColor;
  final Color titleColor;

  BgStyle get bgStyle => BgStyle.values[bgStyleIndex.clamp(0, BgStyle.values.length - 1)];

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? autoWallpaper,
    int? intervalMinutes,
    int? bgStyleIndex,
    double? fontScale,
    int? textAlignIndex,
    int? fontFamilyIndex,
    Color? bgColor1,
    Color? bgColor2,
    Color? textColor,
    Color? titleColor,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      autoWallpaper: autoWallpaper ?? this.autoWallpaper,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      bgStyleIndex: bgStyleIndex ?? this.bgStyleIndex,
      fontScale: fontScale ?? this.fontScale,
      textAlignIndex: textAlignIndex ?? this.textAlignIndex,
      fontFamilyIndex: fontFamilyIndex ?? this.fontFamilyIndex,
      bgColor1: bgColor1 ?? this.bgColor1,
      bgColor2: bgColor2 ?? this.bgColor2,
      textColor: textColor ?? this.textColor,
      titleColor: titleColor ?? this.titleColor,
    );
  }
}

// ─── Settings Notifier ────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;

  void _loadFromPrefs() {
    state = AppSettings(
      isDarkMode: _prefs.getBool(AppConstants.prefKeyDarkMode) ?? false,
      language: _prefs.getString(AppConstants.prefKeyLanguage) ?? AppConstants.langAr,
      autoWallpaper: _prefs.getBool(AppConstants.prefKeyAutoWallpaper) ?? true,
      intervalMinutes: _prefs.getInt(AppConstants.prefKeyIntervalMinutes) ??
          AppConstants.defaultIntervalMinutes,
      bgStyleIndex: _prefs.getInt(AppConstants.prefKeyBgStyle) ?? 0,
      fontScale: _prefs.getDouble(AppConstants.prefKeyFontScale) ?? 1.0,
      textAlignIndex: _prefs.getInt(AppConstants.prefKeyTextAlign) ?? 0,
      fontFamilyIndex: _prefs.getInt(AppConstants.prefKeyFontFamily) ?? 0,
      bgColor1: Color(_prefs.getInt(AppConstants.prefKeyBgColor1) ?? const Color(0xFFF5DEB3).value),
      bgColor2: Color(_prefs.getInt(AppConstants.prefKeyBgColor2) ?? const Color(0xFF8B5E3C).value),
      textColor: Color(_prefs.getInt(AppConstants.prefKeyTextColor) ?? const Color(0xFF2C1A0E).value),
      titleColor: Color(_prefs.getInt(AppConstants.prefKeyTitleColor) ?? const Color(0xFF8B4513).value),
    );
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(AppConstants.prefKeyDarkMode, value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(AppConstants.prefKeyLanguage, lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setAutoWallpaper(bool value) async {
    await _prefs.setBool(AppConstants.prefKeyAutoWallpaper, value);
    state = state.copyWith(autoWallpaper: value);
    if (value) {
      await BackgroundService.scheduleTask(state.intervalMinutes);
    } else {
      await BackgroundService.cancelTask();
    }
  }

  Future<void> setInterval(int minutes) async {
    await _prefs.setInt(AppConstants.prefKeyIntervalMinutes, minutes);
    state = state.copyWith(intervalMinutes: minutes);
    if (state.autoWallpaper) {
      await BackgroundService.scheduleTask(minutes);
    }
  }

  Future<void> setBgStyle(int index) async {
    await _prefs.setInt(AppConstants.prefKeyBgStyle, index);
    state = state.copyWith(bgStyleIndex: index);
  }

  Future<void> setFontScale(double scale) async {
    await _prefs.setDouble(AppConstants.prefKeyFontScale, scale);
    state = state.copyWith(fontScale: scale);
  }

  Future<void> setTextAlign(int index) async {
    await _prefs.setInt(AppConstants.prefKeyTextAlign, index);
    state = state.copyWith(textAlignIndex: index);
  }

  Future<void> setFontFamily(int index) async {
    await _prefs.setInt(AppConstants.prefKeyFontFamily, index);
    state = state.copyWith(fontFamilyIndex: index);
  }

  Future<void> setBgColor1(Color color) async {
    await _prefs.setInt(AppConstants.prefKeyBgColor1, color.value);
    state = state.copyWith(bgColor1: color);
  }

  Future<void> setBgColor2(Color color) async {
    await _prefs.setInt(AppConstants.prefKeyBgColor2, color.value);
    state = state.copyWith(bgColor2: color);
  }

  Future<void> setTextColor(Color color) async {
    await _prefs.setInt(AppConstants.prefKeyTextColor, color.value);
    state = state.copyWith(textColor: color);
  }

  Future<void> setTitleColor(Color color) async {
    await _prefs.setInt(AppConstants.prefKeyTitleColor, color.value);
    state = state.copyWith(titleColor: color);
  }

  void resetDesign() {
    const defaults = AppSettings();
    setBgColor1(defaults.bgColor1);
    setBgColor2(defaults.bgColor2);
    setTextColor(defaults.textColor);
    setTitleColor(defaults.titleColor);
    setFontScale(defaults.fontScale);
    setTextAlign(defaults.textAlignIndex);
    setBgStyle(defaults.bgStyleIndex);
  }
}

// ─── SharedPreferences Provider ────────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// ─── Settings Provider ─────────────────────────────────────────────────────────
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
