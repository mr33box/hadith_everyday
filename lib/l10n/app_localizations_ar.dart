// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'حديث اليوم';

  @override
  String get homeTitle => 'حديث اليوم';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get todayHadith => 'حديث اليوم';

  @override
  String get history => 'السجل';

  @override
  String get noHadiths => 'لا توجد أحاديث بعد. اضغط الزر أدناه لجلب أول حديث.';

  @override
  String get fetchNow => 'حديث جديد';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get loadingHadith => 'جارٍ جلب الحديث...';

  @override
  String get generatingImage => 'جارٍ إنشاء الصورة...';

  @override
  String get settingWallpaper => 'جارٍ تعيين الخلفية...';

  @override
  String get successWallpaper => 'تم تحديث خلفية الشاشة الرئيسية والقفل بنجاح!';

  @override
  String get errorNoInternet => 'لا يوجد إنترنت. يتم عرض حديث محلي.';

  @override
  String get errorApiFailure => 'فشل جلب الحديث. الرجاء المحاولة مجدداً.';

  @override
  String get errorEmptyResponse => 'لم يُعثر على حديث. يرجى المحاولة لاحقاً.';

  @override
  String get errorGeneral => 'حدث خطأ ما. يرجى المحاولة مجدداً.';

  @override
  String get errorWallpaper => 'فشل تعيين الخلفية. يرجى منح الإذن.';

  @override
  String get settingsGeneral => 'عام';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageEn => 'الإنجليزية';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsWallpaper => 'الخلفية';

  @override
  String get settingsAutoWallpaper => 'خلفية تلقائية';

  @override
  String get settingsAutoWallpaperDesc => 'تحديث الخلفية تلقائياً';

  @override
  String get settingsInterval => 'فترة التحديث';

  @override
  String get settingsIntervalDesc => 'عدد مرات جلب حديث جديد';

  @override
  String get settingsImageCustom => 'تخصيص الصورة';

  @override
  String get settingsBgColor => 'نمط الخلفية';

  @override
  String get settingsBgWarm => 'دافئ';

  @override
  String get settingsBgDark => 'داكن';

  @override
  String get settingsBgLight => 'فاتح';

  @override
  String get settingsBgCustom => 'مخصص';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsTextAlign => 'محاذاة النص';

  @override
  String get settingsTextAlignCenter => 'توسيط';

  @override
  String get settingsTextAlignRight => 'يمين';

  @override
  String get settingsTextAlignLeft => 'يسار';

  @override
  String get settingsOpenEditor => 'فتح محرر الصورة';

  @override
  String get settingsOpenEditorDesc => 'تخصيص التصميم ومعاينته مباشرةً';

  @override
  String get intervalHour => 'ساعة واحدة';

  @override
  String get intervalSixHours => '٦ ساعات';

  @override
  String get intervalTwelveHours => '١٢ ساعة';

  @override
  String get intervalDay => '٢٤ ساعة';

  @override
  String get intervalThreeDays => '٣ أيام';

  @override
  String get intervalWeek => '٧ أيام';

  @override
  String get hadithSource => 'رواه';

  @override
  String get hadithBook => 'الكتاب';

  @override
  String get permissionStorageTitle => 'إذن التخزين';

  @override
  String get permissionStorageMsg => 'نحتاج إذن التخزين لحفظ صور الأحاديث.';

  @override
  String get permissionWallpaperTitle => 'إذن الخلفية';

  @override
  String get permissionWallpaperMsg => 'نحتاج إذناً لتعيين خلفية شاشتك.';

  @override
  String get permissionDeny => 'رفض';

  @override
  String get permissionAllow => 'سماح';

  @override
  String get date => 'التاريخ';

  @override
  String get setWallpaperNow => 'تعيين كخلفية';

  @override
  String get share => 'مشاركة';

  @override
  String get delete => 'حذف';

  @override
  String get confirmDelete => 'حذف هذا الحديث من السجل؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get gallery => 'المعرض';

  @override
  String get galleryEmpty => 'لا توجد صور بعد. اجلب حديثاً للبدء.';

  @override
  String get regenerateStyle => 'إعادة التصميم';

  @override
  String get editorTitle => 'تخصيص الصورة';

  @override
  String get editorApply => 'تطبيق';

  @override
  String get editorReset => 'إعادة ضبط';

  @override
  String get editorBackground => 'نمط الخلفية';

  @override
  String get editorBgColors => 'ألوان الخلفية';

  @override
  String get editorTextColors => 'ألوان النص';

  @override
  String get editorFontSize => 'حجم الخط';

  @override
  String get editorAlignment => 'محاذاة النص';

  @override
  String get editorDragHint => 'اسحب لتحريك النص';

  @override
  String get colorTop => 'الجزء العلوي';

  @override
  String get colorBottom => 'الجزء السفلي';

  @override
  String get colorHadithText => 'نص الحديث';

  @override
  String get colorTitleSource => 'العنوان والمصدر';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get earlier => 'سابقاً';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get showLess => 'عرض أقل';

  @override
  String totalHadiths(int count) {
    return 'المجموع: $count';
  }

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get aboutAppDesc =>
      'تطبيق حديث اليوم يساعدك على التذكر والتأمل كل يوم.';

  @override
  String get featureDaily => 'حديث يومي';

  @override
  String get featureWallpaper => 'تحديث الخلفية';

  @override
  String get featureCustom => 'تصميم مخصص';

  @override
  String get onboardingWelcome => 'مرحباً بك في حديث اليوم';

  @override
  String get onboardingUpdate =>
      'يقوم التطبيق بتحديث خلفية هاتفك بحديث جديد كل ٢٤ ساعة';

  @override
  String get onboardingCustom => 'يمكنك تخصيص تصميم الخلفية بالكامل';

  @override
  String get startButton => 'ابدأ';
}
