import 'package:flutter/material.dart';

class WeatherCodeUtils {
  static IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code == 1 || code == 2) return Icons.wb_cloudy;
    if (code == 3) return Icons.cloud;
    if (code >= 45 && code <= 48) return Icons.cloud;
    if (code >= 51 && code <= 57) return Icons.grain;
    if (code >= 61 && code <= 67) return Icons.beach_access;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.umbrella;
    if (code >= 85 && code <= 86) return Icons.ac_unit;
    if (code >= 95 && code <= 99) return Icons.flash_on;
    return Icons.help_outline;
  }

  static Color getWeatherColor(int code) {
    if (code == 0) return Colors.orange;
    if (code == 1 || code == 2) return Colors.blueGrey;
    if (code == 3) return Colors.grey;
    if (code >= 45 && code <= 48) return Colors.grey;
    if (code >= 51 && code <= 57) return Colors.blue;
    if (code >= 61 && code <= 67) return Colors.blue;
    if (code >= 71 && code <= 77) return Colors.white;
    if (code >= 80 && code <= 82) return Colors.blue;
    if (code >= 85 && code <= 86) return Colors.lightBlue;
    if (code >= 95 && code <= 99) return Colors.deepPurple;
    return Colors.grey;
  }
}
