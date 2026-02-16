import 'package:flutter/material.dart';

/// Utility class for chart color management
/// Provides a centralized way to get distinct colors for chart series
class ChartColorUtils {
  // Daha ayrıştırılmış renk paleti - birbirinden farklı, ayırt edilebilir renkler
  static const List<Color> _chartColors = [
    Color(0xFF2196F3), // Mavi
    Color(0xFF4CAF50), // Yeşil
    Color(0xFFF44336), // Kırmızı
    Color(0xFFFF9800), // Turuncu
    Color(0xFF9C27B0), // Mor
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFFC107), // Amber
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
    Color(0xFF673AB7), // Deep Purple
    Color(0xFFCDDC39), // Lime
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF8BC34A), // Light Green
    Color(0xFF03A9F4), // Light Blue
    Color(0xFFFFEB3B), // Yellow
  ];

  /// Gets a color for a chart series based on its index
  /// The index is automatically modded by the number of available colors
  /// to ensure we always return a valid color
  ///
  /// [index] - The index of the series (0-based)
  /// Returns a Color from the predefined palette
  static Color getChartColor(int index) {
    return _chartColors[index % _chartColors.length];
  }

  /// Gets the total number of available colors
  static int get colorCount => _chartColors.length;
}

