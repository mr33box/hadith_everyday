// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Daily Hadith';

  @override
  String get homeTitle => 'Daily Hadith';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get todayHadith => 'Today\'s Hadith';

  @override
  String get history => 'History';

  @override
  String get noHadiths =>
      'No hadiths yet. Tap the button below to fetch your first hadith.';

  @override
  String get fetchNow => 'New Hadith';

  @override
  String get retryButton => 'Retry';

  @override
  String get loadingHadith => 'Fetching hadith...';

  @override
  String get generatingImage => 'Generating image...';

  @override
  String get settingWallpaper => 'Setting wallpaper...';

  @override
  String get successWallpaper => 'Wallpaper updated on home & lock screen!';

  @override
  String get errorNoInternet => 'No internet. Showing local hadith.';

  @override
  String get errorApiFailure => 'Failed to fetch hadith. Please try again.';

  @override
  String get errorEmptyResponse => 'No hadith found. Please try again later.';

  @override
  String get errorGeneral => 'Something went wrong. Please try again.';

  @override
  String get errorWallpaper =>
      'Failed to set wallpaper. Please grant permission.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageAr => 'Arabic';

  @override
  String get settingsWallpaper => 'Wallpaper';

  @override
  String get settingsAutoWallpaper => 'Auto Wallpaper';

  @override
  String get settingsAutoWallpaperDesc => 'Automatically update wallpaper';

  @override
  String get settingsInterval => 'Update Interval';

  @override
  String get settingsIntervalDesc => 'How often to fetch a new hadith';

  @override
  String get settingsImageCustom => 'Image Customization';

  @override
  String get settingsBgColor => 'Background Style';

  @override
  String get settingsBgWarm => 'Warm';

  @override
  String get settingsBgDark => 'Dark';

  @override
  String get settingsBgLight => 'Light';

  @override
  String get settingsBgCustom => 'Custom';

  @override
  String get settingsFontSize => 'Font Size';

  @override
  String get settingsTextAlign => 'Text Alignment';

  @override
  String get settingsTextAlignCenter => 'Center';

  @override
  String get settingsTextAlignRight => 'Right';

  @override
  String get settingsTextAlignLeft => 'Left';

  @override
  String get settingsOpenEditor => 'Open Image Editor';

  @override
  String get settingsOpenEditorDesc => 'Customize design and preview live';

  @override
  String get intervalHour => '1 Hour';

  @override
  String get intervalSixHours => '6 Hours';

  @override
  String get intervalTwelveHours => '12 Hours';

  @override
  String get intervalDay => '24 Hours';

  @override
  String get intervalThreeDays => '3 Days';

  @override
  String get intervalWeek => '7 Days';

  @override
  String get hadithSource => 'Narrated by';

  @override
  String get hadithBook => 'Book';

  @override
  String get permissionStorageTitle => 'Storage Permission';

  @override
  String get permissionStorageMsg =>
      'Need storage access to save hadith images.';

  @override
  String get permissionWallpaperTitle => 'Wallpaper Permission';

  @override
  String get permissionWallpaperMsg => 'Need permission to set your wallpaper.';

  @override
  String get permissionDeny => 'Deny';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get date => 'Date';

  @override
  String get setWallpaperNow => 'Set as Wallpaper';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Delete this hadith from history?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get gallery => 'Gallery';

  @override
  String get galleryEmpty => 'No images yet. Fetch a hadith to get started.';

  @override
  String get regenerateStyle => 'Regenerate Style';

  @override
  String get editorTitle => 'Customize Design';

  @override
  String get editorApply => 'Apply';

  @override
  String get editorReset => 'Reset';

  @override
  String get editorBackground => 'Background Style';

  @override
  String get editorBgColors => 'Background Colors';

  @override
  String get editorTextColors => 'Text Colors';

  @override
  String get editorFontSize => 'Font Size';

  @override
  String get editorAlignment => 'Text Alignment';

  @override
  String get editorDragHint => 'Drag to reposition text';

  @override
  String get colorTop => 'Top';

  @override
  String get colorBottom => 'Bottom';

  @override
  String get colorHadithText => 'Hadith Text';

  @override
  String get colorTitleSource => 'Title & Source';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get earlier => 'Earlier';

  @override
  String get showMore => 'Show More';

  @override
  String get showLess => 'Show Less';

  @override
  String totalHadiths(int count) {
    return 'Total: $count';
  }

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutAppDesc =>
      'Daily Hadith app that helps you remember and reflect every day.';

  @override
  String get featureDaily => 'Daily hadith';

  @override
  String get featureWallpaper => 'Wallpaper update';

  @override
  String get featureCustom => 'Custom design';

  @override
  String get onboardingWelcome => 'Welcome to Daily Hadith';

  @override
  String get onboardingUpdate =>
      'App updates your wallpaper with a new hadith every 24 hours';

  @override
  String get onboardingCustom => 'You can fully customize the wallpaper design';

  @override
  String get startButton => 'Start';
}
