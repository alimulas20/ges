import 'package:flutter/foundation.dart';

class UrlConstants {
  static const String baseUrl = "https://pms-demo.smartplant360.com";
static const String predictionPath = "services/prediction";
  // API endpoint paths
  static const String loggerPath = "/services/logger";
  static const String loggerTestPath = "/services/loggerTest";

  /// Ortama göre doğru API URL'sini döndürür
  static String getApiUrl() {
    // Debug modunda test URL'sini, production'da normal URL'yi kullan
    if (kDebugMode) {
      return '$baseUrl$loggerTestPath';
    } else {
      return '$baseUrl$loggerPath';
    }
  }
  static String getPredictionApiUrl(){
    return '$baseUrl$predictionPath';
  }
  /// Alternatif: Belirli bir endpoint için URL oluşturur
  static String buildUrl(String endpoint) {
    final String basePath = kDebugMode ? loggerTestPath : loggerPath;
    return '$baseUrl$basePath$endpoint';
  }
}
