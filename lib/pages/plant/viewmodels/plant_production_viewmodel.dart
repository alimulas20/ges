import 'dart:math';

import 'package:flutter/material.dart';

import '../models/plant_production_model.dart';
import '../services/plant_service.dart';

class PlantProductionViewModel with ChangeNotifier {
  final PlantService _service;
  final int plantId;

  // Data
  PlantProductionDTO? _productionData;
  List<ProductionDataPointDTO>? _predictionData;
  double? _predictedTotalEnergy;
  ProductionTimePeriod _selectedTimePeriod = ProductionTimePeriod.daily;
  DateTime _selectedDate = DateTime.now();

  // States
  String? _errorMessage;
  String? _bottomDescription;
  bool _isLoading = false;

  PlantProductionViewModel(this._service, this.plantId) {
    _fetchProductionData();
  }

  // Getters
  PlantProductionDTO? get productionData => _productionData;
  List<ProductionDataPointDTO>? get predictionData => _predictionData;
  double? get predictedTotalEnergy => _predictedTotalEnergy;
  ProductionTimePeriod get selectedTimePeriod => _selectedTimePeriod;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get bottomDescription => _bottomDescription;

  Future<void> _fetchProductionData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _productionData = await _service.getPlantProductionByDate(plantId, _selectedTimePeriod, _selectedDate);

      // Prediction verilerini sadece bugün ve günlük periyotta yükle
      final today = DateTime.now();
      final isToday = _selectedDate.year == today.year && _selectedDate.month == today.month && _selectedDate.day == today.day;

      if (_selectedTimePeriod == ProductionTimePeriod.daily && isToday && _productionData != null && _productionData!.dataPoints.isNotEmpty) {
        try {
          final predictionResponse = await _service.getPlantProductionPrediction(plantId, _selectedTimePeriod, _selectedDate);

          // Gerçek verinin son saatinden sonrasını filtrele (geleceğe yönelik tahminler)
          final lastRealDataTime = _productionData!.dataPoints.last.timestamp;
          _predictionData =
              predictionResponse.dataPoints.where((prediction) {
                return prediction.timestamp.isAfter(lastRealDataTime);
              }).toList();

          // Gelecek saatlerin tahmin toplamını hesapla (kWh cinsinden)
          // Her saatlik tahmin güç değeri (kW), saat başına enerji (kWh) olarak kabul edilir
          double futurePredictionTotal = 0.0;
          if (_predictionData != null && _predictionData!.isNotEmpty) {
            // Her tahmin noktası saatlik güç (kW) değeri, bunu kWh'ye çevirmek için topluyoruz
            // Genellikle saatlik veriler olduğu için her değer 1 saatlik üretimi temsil eder
            futurePredictionTotal = _predictionData!.fold(0.0, (sum, point) => sum + point.totalProduction);
          }

          // Bugün tahmin edilen üretim = Mevcut gerçek üretim + Gelecek saatlerin tahmin toplamı
          _predictedTotalEnergy = _productionData!.totalProduction + futurePredictionTotal;
        } catch (e) {
          // Prediction hatası kritik değil, sadece log'la
          _predictionData = null;
          _predictedTotalEnergy = null;
        }
      } else {
        _predictionData = null;
        _predictedTotalEnergy = null;
      }

      var prodList = _productionData?.dataPoints.map((d) => d.totalProduction).toList() ?? [];
      switch (_selectedTimePeriod) {
        case ProductionTimePeriod.daily:
          final maxValue = prodList.isEmpty ? 0 : _productionData!.dataPoints.map((d) => d.totalProduction).reduce(max);
          _bottomDescription = "Maksimum Güç : $maxValue kW";
          break;
        default:
          _bottomDescription = 'Maksimum Üretim: ${_productionData?.dataPoints.map((e) => e.totalProduction).reduce(max).toStringAsFixed(2)} kWh';
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Üretim verileri alınamadı: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedTimePeriod(ProductionTimePeriod period) {
    _selectedTimePeriod = period;
    _fetchProductionData();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _fetchProductionData();
  }

  void refresh() {
    _fetchProductionData();
  }
}
