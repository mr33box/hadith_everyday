import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/domain/entities/image_style.dart';

/// Synchronous CustomPainter for instant live preview in the editor.
/// Mirrors the HadithImageGenerator rendering — no file I/O.
class HadithPreviewPainter extends CustomPainter {
  const HadithPreviewPainter({
    required this.hadith,
    required this.style,
    required this.titleString,
    required this.sourceString,
    required this.isRtl,
  });

  final HadithEntity hadith;
  final ImageStyle style;
  final String titleString;
  final String sourceString;
  final bool isRtl;

  BgStyle get bgStyle => BgStyle.values[style.bgStyleIndex.clamp(0, BgStyle.values.length - 1)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Background ──────────────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = _gradient(w, h),
    );

    // ── Decorative circles ──────────────────────────────────────────────────
    final gColor = (style.titleColor ?? _goldColor).withOpacity(0.10);
    canvas.drawCircle(Offset.zero, w * 0.18, Paint()..color = gColor);
    canvas.drawCircle(Offset(w, h), w * 0.22, Paint()..color = gColor);

    // ── Font sizes (scaled to canvas width) ─────────────────────────────────
    final titleSize  = 20.0 * style.fontScale * (w / 400);
    final bodySize   = _autoBodySize(hadith.getLocalizedText(isRtl).length, style.fontScale) * (w / 400);
    final sourceSize = 14.0 * style.fontScale * (w / 400);

    final titleCol  = style.titleColor ?? _goldColor;
    final bodyCol   = style.textColor ?? _bodyColor;
    final padH      = w * 0.08;
    final maxW      = w - padH * 2;

    // ── Text painters ───────────────────────────────────────────────────────
    final titleP = _tp(titleString, titleSize, titleCol,
        FontWeight.w700, TextAlign.center, maxW);
    final bodyP  = _tp(hadith.getLocalizedText(isRtl), bodySize, bodyCol,
        FontWeight.normal, style.alignment, maxW);
    final srcP   = _tp(sourceString, sourceSize,
        titleCol.withOpacity(0.85), FontWeight.w500, TextAlign.center, maxW);

    titleP.layout(minWidth: maxW, maxWidth: maxW);
    bodyP.layout(minWidth: maxW, maxWidth: maxW);
    srcP.layout(minWidth: maxW, maxWidth: maxW);

    // ── Vertical centering ──────────────────────────────────────────────────
    const divH    = 0.003;
    final gapTD   = h * 0.016;
    final gapDB   = h * 0.020;
    final gapBS   = h * 0.022;
    final totalH  = titleP.height + gapTD + h * divH + gapDB +
        bodyP.height + gapBS + srcP.height;
    final double defaultStartY = (h - totalH) / 2;
    // Map textPosY fraction to actual pixel bounds representing the anchor center
    final double centerOffsetPixels = (style.textPosY * h) - (h / 2);
    final double startY = (defaultStartY + centerOffsetPixels).clamp(h * 0.05, h * 0.85);

    final divY    = startY + titleP.height + gapTD;
    final bodyY   = divY + h * divH + gapDB;
    final srcY    = bodyY + bodyP.height + gapBS;

    // ── Paint title (always centered) ───────────────────────────────────────
    titleP.paint(canvas, Offset((w - titleP.width) / 2, startY));

    // ── Divider line ────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(padH * 2, divY),
      Offset(w - padH * 2, divY),
      Paint()
        ..color = titleCol.withOpacity(0.35)
        ..strokeWidth = 0.8,
    );

    // ── Paint body text at correct X for alignment ──────────────────────────
    // TextPainter centers/right-aligns text WITHIN its layout box (maxW).
    // We always start the box from padH so alignment stays within margins.
    bodyP.paint(canvas, Offset(padH, bodyY));

    // ── Paint source (always centered) ──────────────────────────────────────
    srcP.paint(canvas, Offset((w - srcP.width) / 2, srcY));

    // ── Bottom decorative dots ──────────────────────────────────────────────
    _drawDots(canvas, w, h, titleCol);
  }

  @override
  bool shouldRepaint(HadithPreviewPainter old) =>
      old.style != style ||
      old.hadith.id != hadith.id;

  // ── Private helpers ────────────────────────────────────────────────────────

  Color get _goldColor => switch (bgStyle) {
        BgStyle.dark   => const Color(0xFFD4AF37),
        BgStyle.warm   => const Color(0xFF8B4513),
        BgStyle.light  => const Color(0xFF8B6914),
        BgStyle.custom => const Color(0xFFD4AF37),
      };

  Color get _bodyColor => switch (bgStyle) {
        BgStyle.dark   => const Color(0xFFF5ECD7),
        BgStyle.warm   => const Color(0xFF2C1A0E),
        BgStyle.light  => const Color(0xFF1A1A2E),
        BgStyle.custom => const Color(0xFFF5ECD7),
      };

  ui.Gradient _gradient(double w, double h) {
    final List<Color> cols;
    if (bgStyle == BgStyle.custom &&
        style.bgColor1 != null &&
        style.bgColor2 != null) {
      cols = [
        style.bgColor1!,
        Color.lerp(style.bgColor1!, style.bgColor2!, 0.4)!,
        style.bgColor2!,
      ];
    } else {
      cols = switch (bgStyle) {
        BgStyle.warm  => const [Color(0xFFF5DEB3), Color(0xFFDEB887), Color(0xFF8B5E3C)],
        BgStyle.dark  => const [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF1A1A2E)],
        BgStyle.light => const [Color(0xFFFFFBF0), Color(0xFFEEE4C4), Color(0xFFF5ECD7)],
        BgStyle.custom => const [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF1A1A2E)],
      };
    }
    return ui.Gradient.linear(
      Offset.zero, Offset(0, h),
      cols,
      List.generate(cols.length, (i) => i / (cols.length - 1)),
    );
  }

  void _drawDots(Canvas canvas, double w, double h, Color c) {
    final p = Paint()..color = c.withOpacity(0.4);
    final r = w * 0.005;
    final sp = w * 0.02;
    const n = 5;
    final sx = w / 2 - (n - 1) * sp / 2;
    for (int i = 0; i < n; i++) {
      canvas.drawCircle(Offset(sx + i * sp, h * 0.95), r, p);
    }
  }

  double _autoBodySize(int len, double scale) {
    if (len < 80)  return 20 * scale;
    if (len < 150) return 18 * scale;
    if (len < 250) return 16 * scale;
    if (len < 350) return 14 * scale;
    if (len < 450) return 12.5 * scale;
    return 11.5 * scale;
  }

  TextPainter _tp(String text, double size, Color color, FontWeight weight,
      TextAlign align, double maxW) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: 1.65,
          fontFamily: 'Cairo',
        ),
      ),
      textAlign: align,
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
    );
  }
}
