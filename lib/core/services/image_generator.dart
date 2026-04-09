import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';

/// Hadith background color styles
enum BgStyle { warm, dark, light, custom }

/// Generates a full-screen styled wallpaper image using Flutter's dart:ui Canvas.
/// Supports device-native resolution for a perfect wallpaper fit.
class HadithImageGenerator {
  /// Creates a wallpaper PNG and saves it to app documents.
  /// Returns the local file path on success.
  ///
  /// Pass [deviceWidth] and [deviceHeight] (in logical pixels multiplied by
  /// [devicePixelRatio]) for a perfect full-screen fit on the target device.
  static Future<(String?, Failure?)> generateAndSave({
    required HadithEntity hadith,
    BgStyle bgStyle = BgStyle.warm,
    double fontScale = 1.0,
    TextAlign textAlign = TextAlign.center,
    // Device-native dimensions
    double? deviceWidth,
    double? deviceHeight,
    // Localization
    required String titleString,
    required String sourceString,
    required bool isRtl,
    // Custom colors (used when bgStyle == BgStyle.custom)
    Color? customBgColor1,
    Color? customBgColor2,
    Color? customTextColor,
    Color? customTitleColor,
  }) async {
    try {
      final bytes = await _renderToBytes(
        hadith: hadith,
        bgStyle: bgStyle,
        fontScale: fontScale,
        textAlign: textAlign,
        titleString: titleString,
        sourceString: sourceString,
        isRtl: isRtl,
        w: deviceWidth ?? AppConstants.wallpaperWidth,
        h: deviceHeight ?? AppConstants.wallpaperHeight,
        customBgColor1: customBgColor1,
        customBgColor2: customBgColor2,
        customTextColor: customTextColor,
        customTitleColor: customTitleColor,
      );
      final path = await _saveToFile(bytes, hadith.id);
      return (path, null);
    } on ImageFailure catch (f) {
      return (null, f);
    } catch (e) {
      return (null, ImageFailure('Image generation failed: $e'));
    }
  }

  // ─── Rendering ──────────────────────────────────────────────────────────────

  static Future<Uint8List> _renderToBytes({
    required HadithEntity hadith,
    required BgStyle bgStyle,
    required double fontScale,
    required TextAlign textAlign,
    required String titleString,
    required String sourceString,
    required bool isRtl,
    required double w,
    required double h,
    Color? customBgColor1,
    Color? customBgColor2,
    Color? customTextColor,
    Color? customTitleColor,
  }) async {
    // Use compact spacing constants relative to height
    final double paddingH = w * 0.074;       // ~80px on 1080
    final double paddingTop = h * 0.08;      // top safe zone
    final double paddingBottom = h * 0.06;   // bottom safe zone

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    // ── Background gradient ───────────────────────────────────────────────────
    final gradient = _buildGradient(bgStyle, w, h,
        color1: customBgColor1, color2: customBgColor2);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = gradient);

    // ── Decorative ornaments (overlay circles) ────────────────────────────────
    _drawOrnament(canvas, w, h, bgStyle, customBgColor1: customBgColor1);

    // ── Calculate vertical layout ─────────────────────────────────────────────
    // We will compute each painter first, then position them in one pass.
    final titleFontSize = 48.0 * fontScale * (w / 1080);
    final bodyFontSize = _computeFontSize(hadith.arabicText.length, fontScale) * (w / 1080);
    final sourceFontSize = 34.0 * fontScale * (w / 1080);

    // Title
    final titlePainter = _buildTextPainter(
      text: titleString,
      fontSize: titleFontSize,
      color: customTitleColor ?? _goldColor(bgStyle),
      fontWeight: FontWeight.bold,
      textAlign: TextAlign.center,
      isRtl: isRtl,
      maxWidth: w - paddingH * 2,
    );
    titlePainter.layout(maxWidth: w - paddingH * 2);

    // Body
    final bodyPainter = _buildTextPainter(
      text: hadith.arabicText,
      fontSize: bodyFontSize,
      color: customTextColor ?? _textColor(bgStyle),
      fontWeight: FontWeight.normal,
      textAlign: textAlign,
      isRtl: isRtl,
      maxWidth: w - paddingH * 2,
    );
    bodyPainter.layout(maxWidth: w - paddingH * 2);

    // Source
    final sourcePainter = _buildTextPainter(
      text: sourceString,
      fontSize: sourceFontSize,
      color: (customTitleColor ?? _goldColor(bgStyle)).withOpacity(0.85),
      fontWeight: FontWeight.w500,
      textAlign: TextAlign.center,
      isRtl: isRtl,
      maxWidth: w - paddingH * 2,
    );
    sourcePainter.layout(maxWidth: w - paddingH * 2);

    // ── Compute vertical layout — CENTERED in image ───────────────────────────
    final double titleBodyGap  = h * 0.025;
    final double dividerHeight = h * 0.004;
    final double dividerGap    = h * 0.018;
    final double bodySourceGap = h * 0.028;

    final double totalContentH =
        titlePainter.height +
        dividerGap +
        dividerHeight +
        titleBodyGap +
        bodyPainter.height +
        bodySourceGap +
        sourcePainter.height;

    // Center the content block vertically; never higher than paddingTop
    final double startY =
        ((h - totalContentH) / 2).clamp(paddingTop, h * 0.55);

    final double dividerY = startY + titlePainter.height + dividerGap;
    final double bodyY    = dividerY + dividerHeight + titleBodyGap;
    final double sourceY  = bodyY + bodyPainter.height + bodySourceGap;

    // If content still overflows, scale down uniformly
    final double bottomEdge = sourceY + sourcePainter.height + paddingBottom;
    final double scale = bottomEdge > h ? h / bottomEdge : 1.0;

    canvas.save();
    if (scale < 1.0) canvas.scale(scale, scale);

    // ── Paint title (centered horizontally) ──────────────────────────────────
    final titleX = (w - titlePainter.width) / 2;
    titlePainter.paint(canvas, Offset(titleX, startY));

    // ── Divider line ──────────────────────────────────────────────────────────
    final dividerPaint = Paint()
      ..color = (customTitleColor ?? _goldColor(bgStyle)).withOpacity(0.45)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(paddingH * 2.5, dividerY),
      Offset(w - paddingH * 2.5, dividerY),
      dividerPaint,
    );

    // ── Hadith body text ──────────────────────────────────────────────────────
    bodyPainter.paint(canvas, Offset(paddingH, bodyY));

    // ── Source label (centered) ───────────────────────────────────────────────
    final sourceX = (w - sourcePainter.width) / 2;
    sourcePainter.paint(canvas, Offset(sourceX, sourceY));

    // ── Bottom decorative dots ────────────────────────────────────────────────
    _drawBottomDots(canvas, w, h, bgStyle, customBgColor1: customBgColor1);

    canvas.restore();

    // ── Render ────────────────────────────────────────────────────────────────
    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw const ImageFailure('Failed to encode image.');
    return byteData.buffer.asUint8List();
  }

  // ─── Text Painter Helper ───────────────────────────────────────────────────

  static TextPainter _buildTextPainter({
    required String text,
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
    required TextAlign textAlign,
    required bool isRtl,
    required double maxWidth,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: 1.65,
          letterSpacing: 0.3,
        ),
      ),
      textAlign: textAlign,
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      maxLines: null,
    );
  }

  // ─── Dynamic Font Sizing ───────────────────────────────────────────────────

  static double _computeFontSize(int charCount, double scale) {
    if (charCount < 80)  return 50 * scale;
    if (charCount < 150) return 44 * scale;
    if (charCount < 250) return 40 * scale;
    if (charCount < 350) return 36 * scale;
    if (charCount < 450) return 32 * scale;
    return 28 * scale;
  }

  // ─── Color Helpers ─────────────────────────────────────────────────────────

  static Color _textColor(BgStyle style) {
    return switch (style) {
      BgStyle.dark   => const Color(0xFFF5ECD7),
      BgStyle.warm   => const Color(0xFF2C1A0E),
      BgStyle.light  => const Color(0xFF1A1A2E),
      BgStyle.custom => const Color(0xFF2C1A0E),
    };
  }

  static Color _goldColor(BgStyle style) {
    return switch (style) {
      BgStyle.dark   => const Color(0xFFD4AF37),
      BgStyle.warm   => const Color(0xFF8B4513),
      BgStyle.light  => const Color(0xFF8B6914),
      BgStyle.custom => const Color(0xFF8B4513),
    };
  }

  // ─── Gradient Builder ──────────────────────────────────────────────────────

  static ui.Gradient _buildGradient(BgStyle style, double w, double h,
      {Color? color1, Color? color2}) {
    final List<Color> colors;
    if (style == BgStyle.custom && color1 != null && color2 != null) {
      colors = [color1, Color.lerp(color1, color2, 0.4)!, color2, color2.withOpacity(0.9)];
    } else {
      colors = switch (style) {
        BgStyle.warm  => [const Color(0xFFF5DEB3), const Color(0xFFDEB887), const Color(0xFFC8965C), const Color(0xFF8B5E3C)],
        BgStyle.dark  => [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460), const Color(0xFF1A1A2E)],
        BgStyle.light => [const Color(0xFFFFFBF0), const Color(0xFFF8F0DC), const Color(0xFFEEE4C4), const Color(0xFFF5ECD7)],
        BgStyle.custom => [const Color(0xFFF5DEB3), const Color(0xFFDEB887), const Color(0xFFC8965C), const Color(0xFF8B5E3C)],
      };
    }

    return ui.Gradient.linear(
      Offset.zero, Offset(0, h),
      colors, [0.0, 0.35, 0.70, 1.0],
    );
  }

  // ─── Decorative Ornaments ──────────────────────────────────────────────────

  static void _drawOrnament(Canvas canvas, double w, double h, BgStyle style,
      {Color? customBgColor1}) {
    final goldColor = customBgColor1 ?? _goldColor(style);
    final paint = Paint()
      ..color = goldColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, w * 0.185, paint);
    canvas.drawCircle(Offset(w, h), w * 0.23, paint);

    final ringPaint = Paint()
      ..color = goldColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, -h * 0.052), w * 0.324, ringPaint);
  }

  static void _drawBottomDots(Canvas canvas, double w, double h, BgStyle style,
      {Color? customBgColor1}) {
    final goldColor = customBgColor1 ?? _goldColor(style);
    final paint = Paint()
      ..color = goldColor.withOpacity(0.50)
      ..style = PaintingStyle.fill;
    final double dotR = w * 0.005;
    final double spacing = w * 0.02;
    const int count = 5;
    final startX = w / 2 - (count - 1) * spacing / 2;
    for (int i = 0; i < count; i++) {
      canvas.drawCircle(Offset(startX + i * spacing, h * 0.942), dotR, paint);
    }
  }

  // ─── File I/O ──────────────────────────────────────────────────────────────

  static Future<String> _saveToFile(Uint8List bytes, int hadithId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/${AppConstants.imagesDirName}');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Delete any existing files for this hadith ID to avoid clutter
      final files = imagesDir.listSync();
      for (var f in files) {
        if (f is File && f.path.contains('hadith_$hadithId')) {
          try { await f.delete(); } catch (_) {}
        }
      }

      // Append timestamp to ensure a perfectly unique fresh path every time
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${imagesDir.path}/hadith_${hadithId}_$timestamp.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      throw ImageFailure('Failed to save image: $e');
    }
  }

  /// Delete all wallpaper images for a given hadith ID.
  static Future<void> deleteImage(int hadithId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/${AppConstants.imagesDirName}');
      if (await imagesDir.exists()) {
        final files = imagesDir.listSync();
        for (var f in files) {
          if (f is File && f.path.contains('hadith_$hadithId')) {
            try { await f.delete(); } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }
}
