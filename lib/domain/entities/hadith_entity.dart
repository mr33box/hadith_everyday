/// Pure domain entity — no serialization, no framework dependencies.
/// This is what use-cases and UI interact with.
class HadithEntity {
  const HadithEntity({
    required this.id,
    required this.hadithNumber,
    required this.arabicText,
    required this.englishText,
    required this.arabicNarrator,
    required this.englishNarrator,
    required this.bookSlug,
    required this.bookName,
    required this.chapterTitle,
    required this.status,
    required this.fetchedAt,
    this.imagePath,
    this.bgStyleIndex,
    this.fontScale,
    this.textAlignIndex,
  });

  /// Unique ID from the API
  final int id;

  /// Hadith number within its book
  final String hadithNumber;

  /// Arabic hadith text
  final String arabicText;

  /// English hadith text
  final String englishText;

  /// Arabic narrator string (e.g. "عن أبي هريرة")
  final String arabicNarrator;

  /// English narrator string
  final String englishNarrator;

  /// Book slug (e.g. "sahih-bukhari")
  final String bookSlug;

  /// Human-readable book name (e.g. "Sahih Bukhari")
  final String bookName;

  /// Chapter title (may be empty)
  final String chapterTitle;

  /// Hadith status (e.g. "Sahih")
  final String status;

  /// When this hadith was fetched and saved locally
  final DateTime fetchedAt;

  /// Path to the locally generated wallpaper image (null until generated)
  final String? imagePath;

  // ─── Style Data (Saved when image is generated) ───────────────────────────
  final int? bgStyleIndex;
  final double? fontScale;
  final int? textAlignIndex;

  /// Returns the source label shown on the wallpaper image
  String get sourceLabel => bookName;

  /// Returns localized book name
  String getLocalizedBookName(bool isAr) {
    if (isAr) {
      final name = bookName.toLowerCase();
      final slug = bookSlug.toLowerCase();
      if (slug.contains('bukhari') || name.contains('bukhari')) return 'البخاري';
      if (slug.contains('muslim') || name.contains('muslim')) return 'مسلم';
      return bookName;
    }
    return bookName;
  }

  /// Returns a short preview of the Arabic text (for list cards)
  String get arabicPreview =>
      arabicText.length > 120 ? '${arabicText.substring(0, 120)}…' : arabicText;

  /// Returns a short preview of the English text
  String get englishPreview =>
      englishText.length > 120
          ? '${englishText.substring(0, 120)}…'
          : englishText;

  HadithEntity copyWith({
    int? id,
    String? hadithNumber,
    String? arabicText,
    String? englishText,
    String? arabicNarrator,
    String? englishNarrator,
    String? bookSlug,
    String? bookName,
    String? chapterTitle,
    String? status,
    DateTime? fetchedAt,
    String? imagePath,
    int? bgStyleIndex,
    double? fontScale,
    int? textAlignIndex,
  }) {
    return HadithEntity(
      id: id ?? this.id,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      arabicText: arabicText ?? this.arabicText,
      englishText: englishText ?? this.englishText,
      arabicNarrator: arabicNarrator ?? this.arabicNarrator,
      englishNarrator: englishNarrator ?? this.englishNarrator,
      bookSlug: bookSlug ?? this.bookSlug,
      bookName: bookName ?? this.bookName,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      status: status ?? this.status,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      imagePath: imagePath ?? this.imagePath,
      bgStyleIndex: bgStyleIndex ?? this.bgStyleIndex,
      fontScale: fontScale ?? this.fontScale,
      textAlignIndex: textAlignIndex ?? this.textAlignIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HadithEntity(id: $id, book: $bookSlug, #$hadithNumber)';
}
