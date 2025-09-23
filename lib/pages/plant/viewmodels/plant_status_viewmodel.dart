import 'package:flutter/material.dart';

import '../../alarm/model/alarm_dto.dart';
import '../../alarm/service/alarm_service.dart';
import '../models/plant_with_latest_weather_dto.dart';
import '../services/plant_service.dart';

class PlantStatusViewModel with ChangeNotifier {
  final PlantService _plantService;
  final AlarmService _alarmService;
  final int plantId;

  PlantWithLatestWeatherDto? _plant;
  List<AlarmDto> _alarms = [];
  bool _isLoading = false;
  String? _errorMessage;

  PlantStatusViewModel(this._plantService, this._alarmService, this.plantId) {
    _loadData();
  }

  PlantWithLatestWeatherDto? get plant => _plant;
  List<AlarmDto> get alarms => _alarms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if plant is online based on system alarms
  bool get isOnline {
    if (_alarms.isEmpty) return true;

    // If there are any system alarms, plant is offline
    return !_alarms.any((alarm) => alarm.source.toLowerCase() == 'system');
  }

  // Get system alarms only
  List<AlarmDto> get systemAlarms {
    return _alarms.where((alarm) => alarm.source.toLowerCase() == 'system').toList();
  }

  // Get non-system alarms for display
  List<AlarmDto> get displayAlarms {
    return _alarms.where((alarm) => alarm.source.toLowerCase() != 'system').toList();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load plant data
      final plants = await _plantService.getPlantswithWeather();
      _plant = plants.firstWhere((p) => p.id == plantId);

      // Load alarms for this plant
      _alarms = await _alarmService.getAlarms(plantId: plantId, activeOnly: true, levels: ['Major', 'Minor', 'Warning']);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Veri yüklenirken hata oluştu: ${e.toString()}';
      debugPrint('Error loading plant status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  Future<AlarmDetailDto> getAlarmDetails(int alarmId) async {
    return await _alarmService.getAlarmDetails(alarmId);
  }
}
