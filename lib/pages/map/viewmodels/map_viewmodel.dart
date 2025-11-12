import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/pv_string_model.dart';
import '../services/map_service.dart';

enum ColorMode { voltage, current, power }

enum ShowMode { last, max }

class MapViewModel with ChangeNotifier {
  final MapService _apiService;
  List<PVStringModel> _pvStrings = [];
  ColorMode _colorMode = ColorMode.power;
  ShowMode _showMode = ShowMode.last;
  PVStringModel? _selectedString;
  bool _isLoading = false;
  String? _errorMessage;

  List<PVStringModel> get pvStrings => _pvStrings;
  ColorMode get colorMode => _colorMode;
  ShowMode get showMode => _showMode;
  PVStringModel? get selectedString => _selectedString;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  set errorMessage(a) => _errorMessage = a;

  MapViewModel(this._apiService);

  Future<void> fetchPVStrings(int plantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getPVStringsWithGeneration(plantId);
      _pvStrings = data;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Veri alınamadı: ${e.toString()}';
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setColorMode(ColorMode mode) {
    _colorMode = mode;
    notifyListeners();
  }

  void setShowMOde(ShowMode mode) {
    _showMode = mode;
    notifyListeners();
  }

  void selectString(PVStringModel? string) {
    _selectedString = string;
    notifyListeners();
  }

  Color getStringColor(PVStringModel string) {
    if (_showMode == ShowMode.last) {
      // Last mode: ortalamaya göre renklendirme
      switch (_colorMode) {
        case ColorMode.voltage:
          final values = _pvStrings.map((e) => (e.lastPVV ?? 0) / e.panelCount).toList();
          final avg = values.reduce((a, b) => a + b) / values.length;
          final minV = values.reduce((a, b) => a < b ? a : b);
          final maxV = values.reduce((a, b) => a > b ? a : b);
          return _getColorByAverage((string.lastPVV ?? 0) / string.panelCount, avg, minV, maxV);

        case ColorMode.current:
          final values = _pvStrings.map((e) => e.lastPVA ?? 0).toList();
          final avg = values.reduce((a, b) => a + b) / values.length;
          final minC = values.reduce((a, b) => a < b ? a : b);
          final maxC = values.reduce((a, b) => a > b ? a : b);
          return _getColorByAverage(string.lastPVA ?? 0, avg, minC, maxC);

        case ColorMode.power:
          final values = _pvStrings.map((e) => (e.lastPower ?? 0) / e.panelCount).toList();
          final avg = values.reduce((a, b) => a + b) / values.length;
          final minP = values.reduce((a, b) => a < b ? a : b);
          final maxP = values.reduce((a, b) => a > b ? a : b);
          return _getColorByAverage((string.lastPower ?? 0) / string.panelCount, avg, minP, maxP);
      }
    } else {
      // Max mode: 0-%100 arası 11 renk aralığı
      switch (_colorMode) {
        case ColorMode.voltage:
          return _getColorByPercentage(string.maxPVV ?? 0, 0, string.panelCount * string.panelType.voltageAtMaxPower);

        case ColorMode.current:
          return _getColorByPercentage(string.maxPVA ?? 0, 0, string.panelType.currentAtMaxPower);

        case ColorMode.power:
          return _getColorByPercentage(string.maxPower ?? 0, 0, string.panelCount * string.panelType.maxPower);
      }
    }
  }

  // 11 renk paleti: Gri, Kırmızı→Sarı (5 ton), Sarı→Yeşil (5 ton)
  static final List<Color> _colorPalette = [
    Colors.grey, // 0: Gri
    const Color(0xFFD32F2F), // 1: Koyu kırmızı
    const Color(0xFFE53935), // 2: Kırmızı
    const Color(0xFFEF5350), // 3: Açık kırmızı
    const Color(0xFFF57C00), // 4: Turuncu-kırmızı
    const Color(0xFFFFB300), // 5: Sarı (orta nokta)
    const Color(0xFFAED581), // 6: Açık yeşil
    const Color(0xFF81C784), // 7: Yeşil
    const Color(0xFF66BB6A), // 8: Orta yeşil
    const Color(0xFF4CAF50), // 9: Koyu yeşil
    const Color(0xFF388E3C), // 10: En koyu yeşil
  ];

  // Max mode: 0-%100 arası 11 renk aralığı (her aralık ~%10)
  Color _getColorByPercentage(double value, double min, double max) {
    if (min == max || value <= min) return _colorPalette[0]; // Gri
    if (value >= max) return _colorPalette[10]; // En koyu yeşil

    final percentage = ((value - min) / (max - min)) * 100;

    // Her aralık yaklaşık %10 (0-10, 10-20, ..., 90-100)
    // 0: Gri (0)
    // 1-5: Kırmızı→Sarı (0-50)
    // 6-10: Sarı→Yeşil (50-100)

    if (percentage == 0) return _colorPalette[0];

    // 0-50 arası: 5 aralık (her biri %10)
    if (percentage < 50) {
      final index = ((percentage / 10).floor()).clamp(0, 4) + 1;
      return _colorPalette[index];
    }

    // 50-100 arası: 5 aralık (her biri %10)
    final index = (((percentage - 50) / 10).floor()).clamp(0, 4) + 6;
    return _colorPalette[index];
  }

  // Last mode: ortalamaya göre renklendirme
  Color _getColorByAverage(double value, double average, double min, double max) {
    // 0 değeri için gri
    if (value == 0.0) return _colorPalette[0]; // Gri

    if (min == max) return _colorPalette[5]; // Sarı (ortalama)

    // Ortalama = sarı (%50 kabul edilecek)
    // Ortalamanın altı: Sarıdan kırmızıya (5 aralık)
    // Ortalamanın üstü: Sarıdan yeşile (5 aralık)

    if (value == average) return _colorPalette[5]; // Sarı

    if (value < average) {
      // Ortalamanın altı: Sarıdan kırmızıya
      final range = average - min;
      if (range == 0) return _colorPalette[5];

      final ratio = (average - value) / range; // 0 (ortalama) -> 1 (min)
      final index = (ratio * 5).floor().clamp(0, 4);
      return _colorPalette[5 - index]; // 4, 3, 2, 1, 0 (sarıdan kırmızıya)
    } else {
      // Ortalamanın üstü: Sarıdan yeşile
      final range = max - average;
      if (range == 0) return _colorPalette[5];

      final ratio = (value - average) / range; // 0 (ortalama) -> 1 (max)
      final index = (ratio * 5).floor().clamp(0, 4);
      return _colorPalette[6 + index]; // 6, 7, 8, 9, 10 (sarıdan yeşile)
    }
  }

  LatLng calculateCenter(List<LatLng> points) {
    double lat = 0, long = 0;
    for (var point in points) {
      lat += point.latitude;
      long += point.longitude;
    }
    return LatLng(lat / points.length, long / points.length);
  }

  List<List<LatLng>> getPolygonPoints() {
    return _pvStrings.expand((string) {
      return string.locationSeries.map((series) {
        return series.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      });
    }).toList();
  }

  List<Color> getPolygonColors() {
    return _pvStrings.expand((string) {
      return string.locationSeries.map((_) {
        return getStringColor(string).withAlpha(126);
      });
    }).toList();
  }

  List<Color> getBorderColors() {
    return _pvStrings.expand((string) {
      return string.locationSeries.map((_) {
        return getStringColor(string);
      });
    }).toList();
  }

  List<PVStringModel> getPolygonStringAssociations() {
    return _pvStrings.expand((string) {
      return string.locationSeries.map((_) => string);
    }).toList();
  }
}
