import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../global/utils/alert_utils.dart';
import '../../plant/services/plant_service.dart';
import '../models/pv_string_model.dart';
import '../services/map_service.dart';

enum ColorMode { voltage, current, power }

enum ShowMode { last, max }

class MapConfigViewModel with ChangeNotifier {
  final MapService _mapService;
  final PlantService _plantService;
  int? _currentPlantId;

  MapConfigViewModel(this._mapService, this._plantService);

  bool _isLoading = false;
  String? _errorMessage;
  List<PVStringModel> _pvStrings = [];
  List<PVStringModel> _allPVStrings = []; // Tüm PV string'ler
  PVStringModel? _selectedPVString;
  bool _isDrawingMode = false;
  bool _isMapEditMode = false;
  final List<LatLng> _currentPolygonPoints = [];
  bool _isSaving = false;
  ColorMode _colorMode = ColorMode.power;
  ShowMode _showMode = ShowMode.last;

  // Görsel kaydırma için offset değerleri
  double _imageOffsetLat = 0.0;
  double _imageOffsetLng = 0.0;

  // Zoom değişikliği için offset
  double _zoomOffset = 0.0;

  // Harita koordinatları
  LatLng? _currentTopLeft;
  LatLng? _currentBottomRight;
  double _currentZoom = 19.6;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PVStringModel> get pvStrings => _pvStrings;
  List<PVStringModel> get allPVStrings => _allPVStrings;
  PVStringModel? get selectedPVString => _selectedPVString;
  bool get isDrawingMode => _isDrawingMode;

  // Seçili location series (polygon tıklama için)
  ({LocationSeries series, PVStringModel pvString})? _selectedLocationSeries;

  ({LocationSeries series, PVStringModel pvString})? get selectedLocationSeries => _selectedLocationSeries;

  void selectLocationSeries(({LocationSeries series, PVStringModel pvString})? locationSeries) {
    _selectedLocationSeries = locationSeries;
    notifyListeners();
  }

  // Inverter'a göre gruplanmış PV String'ler
  Map<String, List<PVStringModel>> get pvStringsByInverter {
    final grouped = <String, List<PVStringModel>>{};
    for (var pvString in _allPVStrings) {
      if (!grouped.containsKey(pvString.inverterName)) {
        grouped[pvString.inverterName] = [];
      }
      grouped[pvString.inverterName]!.add(pvString);
    }
    return grouped;
  }

  // Inverter listesi (unique, sıralı)
  List<String> get inverterNames {
    return pvStringsByInverter.keys.toList()..sort();
  }

  List<LatLng> get currentPolygonPoints => _currentPolygonPoints;
  bool get isSaving => _isSaving;
  // Offset'lerle birlikte güncel koordinatları döndür
  LatLng? get currentTopLeft {
    if (_currentTopLeft == null) return null;
    return LatLng(_currentTopLeft!.latitude + _imageOffsetLat, _currentTopLeft!.longitude + _imageOffsetLng);
  }

  LatLng? get currentBottomRight {
    if (_currentBottomRight == null) return null;
    return LatLng(_currentBottomRight!.latitude + _imageOffsetLat, _currentBottomRight!.longitude + _imageOffsetLng);
  }

  // Orijinal koordinatlar (offset'siz)
  LatLng? get originalTopLeft => _currentTopLeft;
  LatLng? get originalBottomRight => _currentBottomRight;

  // Offset'li zoom level'ı döndür
  double get currentZoom => _currentZoom + _zoomOffset;

  // Orijinal zoom level (offset'siz)
  double get originalZoom => _currentZoom;

  double get zoomOffset => _zoomOffset;
  ColorMode get colorMode => _colorMode;
  ShowMode get showMode => _showMode;
  bool get isMapEditMode => _isMapEditMode;
  double get imageOffsetLat => _imageOffsetLat;
  double get imageOffsetLng => _imageOffsetLng;

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> loadPVStringsWithGeneration(int plantId) async {
    _currentPlantId = plantId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPVStrings = await _mapService.getPVStringsWithGeneration(plantId);
      _pvStrings = _allPVStrings; // Tüm string'leri göster (gruplu dropdown'da gösterilecek)
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'PV String\'ler yüklenemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedPVString(PVStringModel? pvString) {
    _selectedPVString = pvString;
    notifyListeners();
  }

  void toggleDrawingMode() {
    _isDrawingMode = !_isDrawingMode;
    if (!_isDrawingMode) {
      _currentPolygonPoints.clear();
      _selectedPVString = null;
    }
    notifyListeners();
  }

  void toggleMapEditMode() {
    _isMapEditMode = !_isMapEditMode;
    if (!_isMapEditMode) {
      // Edit mode kapanırken offset'leri sıfırla
      _imageOffsetLat = 0.0;
      _imageOffsetLng = 0.0;
      _zoomOffset = 0.0;
    }
    notifyListeners();
  }

  void adjustImageOffset(double deltaLat, double deltaLng) {
    // Kaydırma mantığı: Sağa basınca görsel sola kaysın (koordinatlar azalır)
    // Böylece polygon'lar sağa kaymış görünür
    final offsetLat = -deltaLat * 0.000001;
    final offsetLng = -deltaLng * 0.000001;

    // Offset'leri biriktir
    _imageOffsetLat += offsetLat;
    _imageOffsetLng += offsetLng;
    notifyListeners();
  }

  void resetImageAdjustments() {
    _imageOffsetLat = 0.0;
    _imageOffsetLng = 0.0;
    _zoomOffset = 0.0;
    notifyListeners();
  }

  Future<void> saveImageAdjustments(int plantId) async {
    if (_currentTopLeft == null || _currentBottomRight == null) {
      _errorMessage = 'Koordinatlar bulunamadı';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Offset'li koordinatları hesapla
      final topLeftWithOffset = LatLng(_currentTopLeft!.latitude + _imageOffsetLat, _currentTopLeft!.longitude + _imageOffsetLng);
      final bottomRightWithOffset = LatLng(_currentBottomRight!.latitude + _imageOffsetLat, _currentBottomRight!.longitude + _imageOffsetLng);

      // Zoom offset'ini de hesapla
      final zoomWithOffset = _currentZoom + _zoomOffset;

      // Backend'e gönder (topLeft ve bottomRight koordinatları + zoom level)
      await _plantService.updateMapCoordinates(plantId, topLeftWithOffset.latitude, topLeftWithOffset.longitude, bottomRightWithOffset.latitude, bottomRightWithOffset.longitude, zoomWithOffset);

      // Koordinatları güncelle ve offset'leri sıfırla
      _currentTopLeft = topLeftWithOffset;
      _currentBottomRight = bottomRightWithOffset;
      _imageOffsetLat = 0.0;
      _imageOffsetLng = 0.0;

      // Zoom offset'ini de uygula ve sıfırla
      if (_zoomOffset != 0.0) {
        _currentZoom = zoomWithOffset;
        _zoomOffset = 0.0;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Koordinatlar kaydedilemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void adjustZoomLevel(double deltaZoom, {Function(double)? onZoomChanged}) {
    // Zoom offset'ini biriktir (kaydetme gibi)
    final newZoom = _currentZoom + _zoomOffset + deltaZoom;
    if (newZoom < 0 || newZoom > 25) {
      return; // Zoom sınırları dışına çıkma
    }

    _zoomOffset += deltaZoom;

    // Harita kontrolünü güncelle (callback varsa)
    onZoomChanged?.call(newZoom);

    notifyListeners();
  }

  void addPointToPolygon(LatLng point) {
    if (_isDrawingMode) {
      _currentPolygonPoints.add(point);
      notifyListeners();
    }
  }

  void clearCurrentPolygon() {
    _currentPolygonPoints.clear();
    notifyListeners();
  }

  void updateMapBounds(LatLng? topLeft, LatLng? bottomRight, double zoom) {
    _currentTopLeft = topLeft;
    _currentBottomRight = bottomRight;
    _currentZoom = zoom;
    // Koordinatlar güncellendiğinde offset'leri sıfırla (yeni koordinatlar zaten güncel)
    _imageOffsetLat = 0.0;
    _imageOffsetLng = 0.0;
    _zoomOffset = 0.0;
    notifyListeners();
  }

  Future<void> uploadMapPicture(int plantId, XFile file, double? topLeftLat, double? topLeftLng, double? bottomRightLat, double? bottomRightLng, double? zoomLevel) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _plantService.setMapPicture(plantId, file, topLeftLat, topLeftLng, bottomRightLat, bottomRightLng, zoomLevel);
      // Yükleme sonrası koordinatları güncelle
      if (topLeftLat != null && topLeftLng != null) {
        _currentTopLeft = LatLng(topLeftLat, topLeftLng);
      }
      if (bottomRightLat != null && bottomRightLng != null) {
        _currentBottomRight = LatLng(bottomRightLat, bottomRightLng);
      }
      if (zoomLevel != null) {
        _currentZoom = zoomLevel;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Harita fotoğrafı yüklenemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveMapCoordinates(int plantId) async {
    if (_currentBottomRight == null || _currentTopLeft == null) {
      _errorMessage = 'Lütfen harita koordinatlarını ayarlayın';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _plantService.updateMapCoordinates(plantId, _currentTopLeft!.latitude, _currentTopLeft!.longitude, _currentBottomRight!.latitude, _currentBottomRight!.longitude, _currentZoom);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Koordinatlar kaydedilemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> requestPVGenerationRead(int plantId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _plantService.requestPVGenerationRead(plantId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Okuma isteği gönderilemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveLocationSeries(String name) async {
    if (_selectedPVString == null) {
      _errorMessage = 'Lütfen bir PV String seçin';
      notifyListeners();
      return;
    }

    if (_currentPolygonPoints.length < 3) {
      _errorMessage = 'Polygon için en az 3 nokta gerekli';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final points =
          _currentPolygonPoints.asMap().entries.map((entry) {
            return {'latitude': entry.value.latitude, 'longitude': entry.value.longitude, 'order': entry.key};
          }).toList();

      await _mapService.addLocationSeries(_selectedPVString!.id, name, points);

      // Başarılı olduğunda temizle
      _currentPolygonPoints.clear();
      _selectedPVString = null;
      _isDrawingMode = false;
      _errorMessage = null;

      // PV string'leri yeniden yükle
      if (_currentPlantId != null) {
        await loadPVStringsWithGeneration(_currentPlantId!);
      }
    } catch (e) {
      _errorMessage = 'Location series kaydedilemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Mevcut polygon'ları göster (görüntüleme için)
  List<List<LatLng>> getExistingPolygonPoints() {
    return _pvStrings.expand((string) {
      return string.locationSeries.map((series) {
        return series.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      });
    }).toList();
  }

  // Polygon'ların hangi PV string'e ait olduğunu döndür
  List<PVStringModel> getPolygonStringAssociations() {
    return _pvStrings.expand((string) {
      return string.locationSeries.map((_) => string);
    }).toList();
  }

  // Location series'leri ve PV string'leri birlikte döndür (silme/güncelleme için)
  List<({LocationSeries series, PVStringModel pvString})> getLocationSeriesList() {
    final result = <({LocationSeries series, PVStringModel pvString})>[];
    for (var pvString in _pvStrings) {
      for (var series in pvString.locationSeries) {
        result.add((series: series, pvString: pvString));
      }
    }
    return result;
  }

  // Polygon index'ine göre location series ve PV string'i bul
  ({LocationSeries? series, PVStringModel? pvString}) getLocationSeriesByIndex(int polygonIndex) {
    final allSeries = getLocationSeriesList();
    if (polygonIndex >= 0 && polygonIndex < allSeries.length) {
      return allSeries[polygonIndex];
    }
    return (series: null, pvString: null);
  }

  Future<void> updateLocationSeries(int locationSeriesId, String name, List<LatLng> points) async {
    if (points.length < 3) {
      _errorMessage = 'Polygon için en az 3 nokta gerekli';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pointsData =
          points.asMap().entries.map((entry) {
            return {'latitude': entry.value.latitude, 'longitude': entry.value.longitude, 'order': entry.key};
          }).toList();

      await _mapService.updateLocationSeries(locationSeriesId, name, pointsData);

      _errorMessage = null;

      // PV string'leri yeniden yükle
      if (_currentPlantId != null) {
        await loadPVStringsWithGeneration(_currentPlantId!);
      }
    } catch (e) {
      _errorMessage = 'Location series güncellenemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteLocationSeries(int locationSeriesId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _mapService.deleteLocationSeries(locationSeriesId);

      _errorMessage = null;

      // PV string'leri yeniden yükle
      if (_currentPlantId != null) {
        await loadPVStringsWithGeneration(_currentPlantId!);
      }
    } catch (e) {
      _errorMessage = 'Location series silinemedi: ${AlertUtils.formatErrorMessage(e)}';
      debugPrint('Error: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void setColorMode(ColorMode mode) {
    _colorMode = mode;
    notifyListeners();
  }

  void setShowMode(ShowMode mode) {
    _showMode = mode;
    notifyListeners();
  }

  Color getStringColor(PVStringModel string) {
    if (_showMode == ShowMode.last) {
      // Last mode: ortalamaya göre renklendirme
      switch (_colorMode) {
        case ColorMode.voltage:
          final values = _pvStrings.map((e) => (e.lastPVV ?? 0) / e.panelCount).toList();
          if (values.isEmpty) return Colors.grey;
          final avg = values.reduce((a, b) => a + b) / values.length;
          final minV = values.reduce((a, b) => a < b ? a : b);
          final maxV = values.reduce((a, b) => a > b ? a : b);
          return _getColorByAverage((string.lastPVV ?? 0) / string.panelCount, avg, minV, maxV);

        case ColorMode.current:
          final values = _pvStrings.map((e) => e.lastPVA ?? 0).toList();
          if (values.isEmpty) return Colors.grey;
          final avg = values.reduce((a, b) => a + b) / values.length;
          final minC = values.reduce((a, b) => a < b ? a : b);
          final maxC = values.reduce((a, b) => a > b ? a : b);
          return _getColorByAverage(string.lastPVA ?? 0, avg, minC, maxC);

        case ColorMode.power:
          final values = _pvStrings.map((e) => (e.lastPower ?? 0) / e.panelCount).toList();
          if (values.isEmpty) return Colors.grey;
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
}
