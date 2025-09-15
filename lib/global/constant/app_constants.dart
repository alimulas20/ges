// constants/app_constants.dart

import 'package:flutter/widgets.dart';

class AppConstants {
  /// Padding and margin values

  /// 2.0
  static const double paddingExtraSmall = 2;

  /// 4.0
  static const double paddingSmall = 4;

  /// 8.0
  static const double paddingMedium = 8;

  /// 12.0
  static const double paddingLarge = 12;

  /// 16.0
  static const double paddingExtraLarge = 16;

  /// 20.0
  static const double paddingSuperLarge = 20;

  /// 24.0
  static const double paddingUltraLarge = 24;

  /// 32.0
  static const double paddingHuge = 32;

  /// Border radius values

  /// 4.0
  static const double borderRadiusSmall = 4;

  /// 8.0
  static const double borderRadiusMedium = 8;

  /// 12.0
  static const double borderRadiusLarge = 12;

  /// 16.0
  static const double borderRadiusExtraLarge = 16;

  /// 50.0 (circular)
  static const double borderRadiusCircle = 50;

  /// Icon sizes

  /// 12.0
  static const double iconSizeExtraSmall = 12;

  /// 16.0
  static const double iconSizeSmall = 16;

  /// 20.0
  static const double iconSizeMedium = 20;

  /// 24.0
  static const double iconSizeLarge = 24;

  /// 32.0
  static const double iconSizeExtraLarge = 32;

  /// Font sizes
  /// 8.0
  static const double fontSizeTiny = 8;

  /// 10.0
  static const double fontSizeExtraSmall = 10;

  /// 12.0
  static const double fontSizeSmall = 12;

  /// 14.0
  static const double fontSizeMedium = 14;

  /// 16.0
  static const double fontSizeLarge = 16;

  /// 20.0
  static const double fontSizeExtraLarge = 20;

  /// 24.0 (for titles)
  static const double fontSizeTitle = 24;

  /// 28.0 (for headlines)
  static const double fontSizeHeadline = 28;

  /// Elevation values

  /// 2.0
  static const double elevationSmall = 2;

  /// 4.0
  static const double elevationMedium = 4;

  /// 8.0
  static const double elevationLarge = 8;

  /// Widget sizes

  /// 80.0 (thumbnail images)
  static const double imageThumbnailSize = 80;

  /// 120.0 (medium sized images)
  static const double imageMediumSize = 120;

  /// 200.0 (large images)
  static const double imageLargeSize = 200;

  /// 48.0 (standard button height)
  static const double buttonHeight = 48;

  /// 56.0 (standard text field height)
  static const double textFieldHeight = 56;

  /// 56.0 (standard app bar height)
  static const double appBarHeight = 56;

  /// Animation durations

  /// 150 milliseconds
  static const Duration animationShort = Duration(milliseconds: 150);

  /// 300 milliseconds
  static const Duration animationMedium = Duration(milliseconds: 300);

  /// 500 milliseconds
  static const Duration animationLong = Duration(milliseconds: 500);

  /// Other constants

  /// 1 (max lines for text)
  static const int maxLinesSmall = 1;

  /// 2 (max lines for text)
  static const int maxLinesMedium = 2;

  /// 3 (max lines for text)
  static const int maxLinesLarge = 3;

  /// 2 (decimal places for numbers)
  static const int decimalPlaces = 2;

  /// 10 (items per page)
  static const int defaultPageSize = 10;

  /// 1.5 (chart line thickness)
  static const double chartLineThickness = 1.5;

  /// 8.0 (chart axis font size)
  static const double chartAxisFontSize = 8;

  /// 35.0 (reduced width for left chart axis)
  static const double chartLeftAxisWidth = 35;

  /// 50.0 (large width for left chart axis)
  static const double chartLeftAxisWidthLarge = 50;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x19000000), // %10 opacity siyah
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x29000000), // %16 opacity siyah
      blurRadius: 10,
      spreadRadius: 2,
      offset: Offset(0, 4),
    ),
  ];
}
