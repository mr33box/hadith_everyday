import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith'**
  String get homeTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @todayHadith.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Hadith'**
  String get todayHadith;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHadiths.
  ///
  /// In en, this message translates to:
  /// **'No hadiths yet. Tap the button below to fetch your first hadith.'**
  String get noHadiths;

  /// No description provided for @fetchNow.
  ///
  /// In en, this message translates to:
  /// **'New Hadith'**
  String get fetchNow;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @loadingHadith.
  ///
  /// In en, this message translates to:
  /// **'Fetching hadith...'**
  String get loadingHadith;

  /// No description provided for @generatingImage.
  ///
  /// In en, this message translates to:
  /// **'Generating image...'**
  String get generatingImage;

  /// No description provided for @settingWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Setting wallpaper...'**
  String get settingWallpaper;

  /// No description provided for @successWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper updated on home & lock screen!'**
  String get successWallpaper;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet. Showing local hadith.'**
  String get errorNoInternet;

  /// No description provided for @errorApiFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch hadith. Please try again.'**
  String get errorApiFailure;

  /// No description provided for @errorEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'No hadith found. Please try again later.'**
  String get errorEmptyResponse;

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneral;

  /// No description provided for @errorWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Failed to set wallpaper. Please grant permission.'**
  String get errorWallpaper;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageAr;

  /// No description provided for @settingsWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get settingsWallpaper;

  /// No description provided for @settingsAutoWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Auto Wallpaper'**
  String get settingsAutoWallpaper;

  /// No description provided for @settingsAutoWallpaperDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically update wallpaper'**
  String get settingsAutoWallpaperDesc;

  /// No description provided for @settingsInterval.
  ///
  /// In en, this message translates to:
  /// **'Update Interval'**
  String get settingsInterval;

  /// No description provided for @settingsIntervalDesc.
  ///
  /// In en, this message translates to:
  /// **'How often to fetch a new hadith'**
  String get settingsIntervalDesc;

  /// No description provided for @settingsImageCustom.
  ///
  /// In en, this message translates to:
  /// **'Image Customization'**
  String get settingsImageCustom;

  /// No description provided for @settingsBgColor.
  ///
  /// In en, this message translates to:
  /// **'Background Style'**
  String get settingsBgColor;

  /// No description provided for @settingsBgWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get settingsBgWarm;

  /// No description provided for @settingsBgDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsBgDark;

  /// No description provided for @settingsBgLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsBgLight;

  /// No description provided for @settingsBgCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get settingsBgCustom;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsFontSize;

  /// No description provided for @settingsTextAlign.
  ///
  /// In en, this message translates to:
  /// **'Text Alignment'**
  String get settingsTextAlign;

  /// No description provided for @settingsTextAlignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get settingsTextAlignCenter;

  /// No description provided for @settingsTextAlignRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get settingsTextAlignRight;

  /// No description provided for @settingsTextAlignLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get settingsTextAlignLeft;

  /// No description provided for @settingsOpenEditor.
  ///
  /// In en, this message translates to:
  /// **'Open Image Editor'**
  String get settingsOpenEditor;

  /// No description provided for @settingsOpenEditorDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize design and preview live'**
  String get settingsOpenEditorDesc;

  /// No description provided for @intervalHour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour'**
  String get intervalHour;

  /// No description provided for @intervalSixHours.
  ///
  /// In en, this message translates to:
  /// **'6 Hours'**
  String get intervalSixHours;

  /// No description provided for @intervalTwelveHours.
  ///
  /// In en, this message translates to:
  /// **'12 Hours'**
  String get intervalTwelveHours;

  /// No description provided for @intervalDay.
  ///
  /// In en, this message translates to:
  /// **'24 Hours'**
  String get intervalDay;

  /// No description provided for @intervalThreeDays.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get intervalThreeDays;

  /// No description provided for @intervalWeek.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get intervalWeek;

  /// No description provided for @hadithSource.
  ///
  /// In en, this message translates to:
  /// **'Narrated by'**
  String get hadithSource;

  /// No description provided for @hadithBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get hadithBook;

  /// No description provided for @permissionStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission'**
  String get permissionStorageTitle;

  /// No description provided for @permissionStorageMsg.
  ///
  /// In en, this message translates to:
  /// **'Need storage access to save hadith images.'**
  String get permissionStorageMsg;

  /// No description provided for @permissionWallpaperTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper Permission'**
  String get permissionWallpaperTitle;

  /// No description provided for @permissionWallpaperMsg.
  ///
  /// In en, this message translates to:
  /// **'Need permission to set your wallpaper.'**
  String get permissionWallpaperMsg;

  /// No description provided for @permissionDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get permissionDeny;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionAllow;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @setWallpaperNow.
  ///
  /// In en, this message translates to:
  /// **'Set as Wallpaper'**
  String get setWallpaperNow;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this hadith from history?'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @galleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No images yet. Fetch a hadith to get started.'**
  String get galleryEmpty;

  /// No description provided for @regenerateStyle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Style'**
  String get regenerateStyle;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Design'**
  String get editorTitle;

  /// No description provided for @editorApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get editorApply;

  /// No description provided for @editorReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get editorReset;

  /// No description provided for @editorBackground.
  ///
  /// In en, this message translates to:
  /// **'Background Style'**
  String get editorBackground;

  /// No description provided for @editorBgColors.
  ///
  /// In en, this message translates to:
  /// **'Background Colors'**
  String get editorBgColors;

  /// No description provided for @editorTextColors.
  ///
  /// In en, this message translates to:
  /// **'Text Colors'**
  String get editorTextColors;

  /// No description provided for @editorFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get editorFontSize;

  /// No description provided for @editorAlignment.
  ///
  /// In en, this message translates to:
  /// **'Text Alignment'**
  String get editorAlignment;

  /// No description provided for @editorDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reposition text'**
  String get editorDragHint;

  /// No description provided for @colorTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get colorTop;

  /// No description provided for @colorBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get colorBottom;

  /// No description provided for @colorHadithText.
  ///
  /// In en, this message translates to:
  /// **'Hadith Text'**
  String get colorHadithText;

  /// No description provided for @colorTitleSource.
  ///
  /// In en, this message translates to:
  /// **'Title & Source'**
  String get colorTitleSource;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @totalHadiths.
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String totalHadiths(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
