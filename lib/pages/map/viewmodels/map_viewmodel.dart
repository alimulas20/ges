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
      switch (_colorMode) {
        case ColorMode.voltage:
          double minV = _pvStrings.map((e) => (e.lastPVV ?? 0) / e.panelCount).reduce((a, b) => a < b ? a : b);
          double maxV = _pvStrings.map((e) => (e.lastPVV ?? 0) / e.panelCount).reduce((a, b) => a > b ? a : b);
          return _getColorByValue(string.lastPVV ?? 0, minV / 1.6, maxV);

        case ColorMode.current:
          double minC = _pvStrings.map((e) => e.lastPVA ?? 0).reduce((a, b) => a < b ? a : b);
          double maxC = _pvStrings.map((e) => e.lastPVA ?? 0).reduce((a, b) => a > b ? a : b);
          return _getColorByValue(string.lastPVA ?? 0, minC / 1.6, maxC);

        case ColorMode.power:
          double minP = _pvStrings.map((e) => (e.lastPower ?? 0) / e.panelCount).reduce((a, b) => a < b ? a : b);
          double maxP = _pvStrings.map((e) => (e.lastPower ?? 0) / e.panelCount).reduce((a, b) => a > b ? a : b);
          return _getColorByValue(string.lastPower ?? 0, minP / 1.6, maxP);
      }
    } else {
      switch (_colorMode) {
        case ColorMode.voltage:
          return _getColorByValue(string.maxPVV ?? 0, 0, string.panelCount * string.panelType.voltageAtMaxPower);

        case ColorMode.current:
          return _getColorByValue(string.maxPVA ?? 0, 0, string.panelType.currentAtMaxPower);

        case ColorMode.power:
          return _getColorByValue(string.maxPower ?? 0, 0, string.panelCount * string.panelType.maxPower);
      }
    }
  }

  Color _getColorByValue(double value, double min, double max) {
    if (min == max) return Colors.green;
    final normalized = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Color.lerp(Colors.red, Colors.green, normalized)!;
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
