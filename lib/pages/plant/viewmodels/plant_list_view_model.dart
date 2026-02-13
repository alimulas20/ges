import 'package:flutter/material.dart';

import '../../../global/utils/alert_utils.dart';
import '../models/plant_with_latest_weather_dto.dart';
import '../services/plant_service.dart';

class PlantListViewModel with ChangeNotifier {
  final PlantService _plantService;

  List<PlantWithLatestWeatherDto> _plants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlantWithLatestWeatherDto> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PlantListViewModel(this._plantService);

  Future<void> fetchPlants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plants = await _plantService.getPlantswithWeather();
      _errorMessage = null;
    } catch (e) {
      _plants = [];
      _errorMessage = AlertUtils.formatErrorMessage(e);
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
