import 'dart:convert';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';

/// Data model — extends the domain entity with JSON serialization.
/// The data layer maps raw API JSON → HadithModel → HadithEntity.
class HadithModel extends HadithEntity {
  const HadithModel({
    required super.id,
    required super.hadithNumber,
    required super.arabicText,
    required super.englishText,
    required super.arabicNarrator,
    required super.englishNarrator,
    required super.bookSlug,
    required super.bookName,
    required super.chapterTitle,
    required super.status,
    required super.fetchedAt,
    super.imagePath,
    super.bgStyleIndex,
    super.fontScale,
    super.textAlignIndex,
  });

  // ─── From API JSON ──────────────────────────────────────────────────────────

  /// Parse a single hadith object from the API's `data` array.
  factory HadithModel.fromApiJson(Map<String, dynamic> json) {
    final book = json['book'] as Map<String, dynamic>? ?? {};
    final chapter = json['chapter'] as Map<String, dynamic>? ?? {};

    return HadithModel(
      id: json['id'] as int? ?? 0,
      hadithNumber: (json['hadithNumber'] ?? '').toString(),
      arabicText: (json['hadithArabic'] ?? '').toString().trim(),
      englishText: (json['hadithEnglish'] ?? '').toString().trim(),
      arabicNarrator: _extractArabicNarrator(json),
      englishNarrator: (json['englishNarrator'] ?? '').toString().trim(),
      bookSlug: (json['bookSlug'] ?? book['slug'] ?? '').toString(),
      bookName: (book['bookName'] ?? '').toString(),
      chapterTitle: (chapter['chapterArabic'] ??
              chapter['chapterEnglish'] ??
              '')
          .toString()
          .trim(),
      status: (json['status'] ?? 'Sahih').toString(),
      fetchedAt: DateTime.now(),
      imagePath: null,
    );
  }

  static String _extractArabicNarrator(Map<String, dynamic> json) {
    // Some API versions use 'urduNarrator' for Arabic narrator field
    final arabic = json['arabicNarrator'] as String?;
    if (arabic != null && arabic.isNotEmpty) return arabic.trim();
    return '';
  }

  // ─── From Bundled Fallback Asset (assets/hadiths.json) ────────────────────

  /// Parse a hadith from the local fallback JSON asset.
  /// The asset uses a flat structure (no nested book/chapter).
  factory HadithModel.fromLocalFallbackJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] as int? ?? 0,
      hadithNumber: (json['hadithNumber'] ?? '').toString(),
      arabicText: (json['arabicText'] ?? '').toString().trim(),
      englishText: (json['englishText'] ?? '').toString().trim(),
      arabicNarrator: (json['arabicNarrator'] ?? '').toString().trim(),
      englishNarrator: (json['englishNarrator'] ?? '').toString().trim(),
      bookSlug: (json['bookSlug'] ?? '').toString(),
      bookName: (json['bookName'] ?? '').toString(),
      chapterTitle: (json['chapterTitle'] ?? '').toString().trim(),
      status: (json['status'] ?? 'Sahih').toString(),
      fetchedAt: DateTime.now(),
      imagePath: null,
    );
  }

  // ─── From / To Local Storage (Hive stores JSON strings) ───────────────────

  factory HadithModel.fromLocalJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] as int,
      hadithNumber: json['hadithNumber'] as String,
      arabicText: json['arabicText'] as String,
      englishText: json['englishText'] as String,
      arabicNarrator: json['arabicNarrator'] as String? ?? '',
      englishNarrator: json['englishNarrator'] as String? ?? '',
      bookSlug: json['bookSlug'] as String,
      bookName: json['bookName'] as String,
      chapterTitle: json['chapterTitle'] as String? ?? '',
      status: json['status'] as String? ?? 'Sahih',
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      imagePath: json['imagePath'] as String?,
      bgStyleIndex: json['bgStyleIndex'] as int?,
      fontScale: json['fontScale'] == null ? null : (json['fontScale'] as num).toDouble(),
      textAlignIndex: json['textAlignIndex'] as int?,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'hadithNumber': hadithNumber,
      'arabicText': arabicText,
      'englishText': englishText,
      'arabicNarrator': arabicNarrator,
      'englishNarrator': englishNarrator,
      'bookSlug': bookSlug,
      'bookName': bookName,
      'chapterTitle': chapterTitle,
      'status': status,
      'fetchedAt': fetchedAt.toIso8601String(),
      'imagePath': imagePath,
      'bgStyleIndex': bgStyleIndex,
      'fontScale': fontScale,
      'textAlignIndex': textAlignIndex,
    };
  }

  String toLocalJsonString() => jsonEncode(toLocalJson());

  factory HadithModel.fromLocalJsonString(String jsonStr) =>
      HadithModel.fromLocalJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);

  /// Convert domain entity back to model (e.g. after imagePath is added)
  factory HadithModel.fromEntity(HadithEntity entity) {
    return HadithModel(
      id: entity.id,
      hadithNumber: entity.hadithNumber,
      arabicText: entity.arabicText,
      englishText: entity.englishText,
      arabicNarrator: entity.arabicNarrator,
      englishNarrator: entity.englishNarrator,
      bookSlug: entity.bookSlug,
      bookName: entity.bookName,
      chapterTitle: entity.chapterTitle,
      status: entity.status,
      fetchedAt: entity.fetchedAt,
      imagePath: entity.imagePath,
      bgStyleIndex: entity.bgStyleIndex,
      fontScale: entity.fontScale,
      textAlignIndex: entity.textAlignIndex,
    );
  }
}
