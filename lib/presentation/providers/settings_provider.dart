import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/services/background_service.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';
import 'package:hadith_everyday/domain/entities/image_style.dart';

// ─── App Settings Model ────────────────────────────────────────────────────────

class AppSettings {
  const AppSettings({
    this.isDarkMode = false,
    this.language = AppConstants.langAr,
    this.autoWallpaper = true,
    this.intervalMinutes = AppConstants.defaultIntervalMinutes,
    this.imageStyle = ImageStyle.defaultStyle,
  });

  final bool isDarkMode;
  final String language;
  final bool autoWallpaper;
  final int intervalMinutes;
  final ImageStyle imageStyle;

  BgStyle get bgStyle => BgStyle.values[imageStyle.bgStyleIndex.clamp(0, BgStyle.values.length - 1)];

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? autoWallpaper,
    int? intervalMinutes,
    ImageStyle? imageStyle,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      autoWallpaper: autoWallpaper ?? this.autoWallpaper,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      imageStyle: imageStyle ?? this.imageStyle,
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
      imageStyle: ImageStyle(
        bgStyleIndex: _prefs.getInt(AppConstants.prefKeyBgStyle) ?? 0,
        fontScale: _prefs.getDouble(AppConstants.prefKeyFontScale) ?? 1.0,
        textAlignIndex: _prefs.getInt(AppConstants.prefKeyTextAlign) ?? 0,
        bgColor1: Color(_prefs.getInt(AppConstants.prefKeyBgColor1) ?? const Color(0xFFF5DEB3).value),
        bgColor2: Color(_prefs.getInt(AppConstants.prefKeyBgColor2) ?? const Color(0xFF8B5E3C).value),
        textColor: Color(_prefs.getInt(AppConstants.prefKeyTextColor) ?? const Color(0xFF2C1A0E).value),
        titleColor: Color(_prefs.getInt(AppConstants.prefKeyTitleColor) ?? const Color(0xFF8B4513).value),
        textPosX: _prefs.getDouble('pref_text_pos_x') ?? 0.5,
        textPosY: _prefs.getDouble('pref_text_pos_y') ?? 0.5,
      ),
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

  Future<void> updateImageStyle(ImageStyle style) async {
    await _prefs.setInt(AppConstants.prefKeyBgStyle, style.bgStyleIndex);
    await _prefs.setDouble(AppConstants.prefKeyFontScale, style.fontScale);
    await _prefs.setInt(AppConstants.prefKeyTextAlign, style.textAlignIndex);
    await _prefs.setDouble('pref_text_pos_x', style.textPosX);
    await _prefs.setDouble('pref_text_pos_y', style.textPosY);
    if (style.bgColor1 != null) await _prefs.setInt(AppConstants.prefKeyBgColor1, style.bgColor1!.value);
    if (style.bgColor2 != null) await _prefs.setInt(AppConstants.prefKeyBgColor2, style.bgColor2!.value);
    if (style.textColor != null) await _prefs.setInt(AppConstants.prefKeyTextColor, style.textColor!.value);
    if (style.titleColor != null) await _prefs.setInt(AppConstants.prefKeyTitleColor, style.titleColor!.value);
    
    state = state.copyWith(imageStyle: style);
  }

  // Backwards compatibility wrappers leveraging the single source of truth
  Future<void> setBgStyle(int index) => updateImageStyle(state.imageStyle.copyWith(bgStyleIndex: index));
  Future<void> setFontScale(double scale) => updateImageStyle(state.imageStyle.copyWith(fontScale: scale));
  Future<void> setTextAlign(int index) => updateImageStyle(state.imageStyle.copyWith(textAlignIndex: index));
  Future<void> setBgColor1(Color color) => updateImageStyle(state.imageStyle.copyWith(bgColor1: color));
  Future<void> setBgColor2(Color color) => updateImageStyle(state.imageStyle.copyWith(bgColor2: color));
  Future<void> setTextColor(Color color) => updateImageStyle(state.imageStyle.copyWith(textColor: color));
  Future<void> setTitleColor(Color color) => updateImageStyle(state.imageStyle.copyWith(titleColor: color));

  void resetDesign() {
    updateImageStyle(const ImageStyle());
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
