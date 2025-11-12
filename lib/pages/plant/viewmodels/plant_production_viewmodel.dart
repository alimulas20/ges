import 'dart:math';

import 'package:flutter/material.dart';

import '../models/plant_production_model.dart';
import '../services/plant_service.dart';

class PlantProductionViewModel with ChangeNotifier {
  final PlantService _service;
  final int plantId;

  // Data
  PlantProductionDTO? _productionData;
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
