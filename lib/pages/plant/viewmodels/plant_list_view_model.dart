import 'package:flutter/material.dart';
import 'package:smart_ges_360/pages/plant/models/plant_with_latest_weather_dto.dart';
import 'package:smart_ges_360/pages/plant/services/plant_service.dart';

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
      _plants = await _plantService.getPlants();
      _errorMessage = null;
    } catch (e) {
      _plants = [];
      _errorMessage = 'Failed to load plants: ${e.toString()}';
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
