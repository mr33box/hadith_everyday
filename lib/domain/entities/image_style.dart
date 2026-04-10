import 'package:flutter/material.dart';

/// A definitive single source of truth for the visual representation of a Hadith wallpaper.
/// Contains position modifiers, scale, alignment, and background parameters.
class ImageStyle {
  const ImageStyle({
    this.textPosX = 0.5,
    this.textPosY = 0.5,
    this.fontScale = 1.0,
    this.textAlignIndex = 0,
    this.bgStyleIndex = 0, 
    // Custom colors (if index is 3)
    this.bgColor1,
    this.bgColor2,
    this.textColor,
    this.titleColor,
  });

  /// Represents the horizontal fraction (0.0 to 1.0) of the canvas area.
  final double textPosX;
  
  /// Represents the vertical fraction (0.0 to 1.0) of the canvas area.
  final double textPosY;
  
  final double fontScale;
  final int textAlignIndex;
  final int bgStyleIndex;

  final Color? bgColor1;
  final Color? bgColor2;
  final Color? textColor;
  final Color? titleColor;

  ImageStyle copyWith({
    double? textPosX,
    double? textPosY,
    double? fontScale,
    int? textAlignIndex,
    int? bgStyleIndex,
    Color? bgColor1,
    Color? bgColor2,
    Color? textColor,
    Color? titleColor,
  }) {
    return ImageStyle(
      textPosX: textPosX ?? this.textPosX,
      textPosY: textPosY ?? this.textPosY,
      fontScale: fontScale ?? this.fontScale,
      textAlignIndex: textAlignIndex ?? this.textAlignIndex,
      bgStyleIndex: bgStyleIndex ?? this.bgStyleIndex,
      bgColor1: bgColor1 ?? this.bgColor1,
      bgColor2: bgColor2 ?? this.bgColor2,
      textColor: textColor ?? this.textColor,
      titleColor: titleColor ?? this.titleColor,
    );
  }

  // Define defaults here avoiding hardcodes elsewhere
  static const ImageStyle defaultStyle = ImageStyle();
  
  // Helpers
  TextAlign get alignment => textAlignIndex == 0 ? TextAlign.center 
                           : textAlignIndex == 1 ? TextAlign.right : TextAlign.left;

  // JSON Serialization for Hive / Prefs if needed
  Map<String, dynamic> toJson() {
    return {
      'textPosX': textPosX,
      'textPosY': textPosY,
      'fontScale': fontScale,
      'textAlignIndex': textAlignIndex,
      'bgStyleIndex': bgStyleIndex,
      'bgColor1': bgColor1?.value,
      'bgColor2': bgColor2?.value,
      'textColor': textColor?.value,
      'titleColor': titleColor?.value,
    };
  }

  factory ImageStyle.fromJson(Map<String, dynamic> json) {
    return ImageStyle(
      textPosX: (json['textPosX'] as num?)?.toDouble() ?? 0.5,
      textPosY: (json['textPosY'] as num?)?.toDouble() ?? 0.5,
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      textAlignIndex: json['textAlignIndex'] as int? ?? 0,
      bgStyleIndex: json['bgStyleIndex'] as int? ?? 0,
      bgColor1: json['bgColor1'] != null ? Color(json['bgColor1'] as int) : null,
      bgColor2: json['bgColor2'] != null ? Color(json['bgColor2'] as int) : null,
      textColor: json['textColor'] != null ? Color(json['textColor'] as int) : null,
      titleColor: json['titleColor'] != null ? Color(json['titleColor'] as int) : null,
    );
  }
}
