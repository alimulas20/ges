import 'package:flutter/material.dart';

import '../../alarm/model/alarm_dto.dart';
import '../../alarm/service/alarm_service.dart';
import '../models/plant_status_dto.dart';
import '../services/plant_service.dart';

class PlantStatusViewModel with ChangeNotifier {
  final PlantService _plantService;
  final AlarmService _alarmService;
  final int plantId;

  PlantStatusDto? _plantStatus;
  bool _isLoading = false;
  String? _errorMessage;

  PlantStatusViewModel(this._plantService, this._alarmService, this.plantId) {
    _loadData();
  }

  PlantStatusDto? get plantStatus => _plantStatus;
  List<AlarmDto> get alarms => _plantStatus?.alarms ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if plant is online based on system alarms
  bool get isOnline {
    if (alarms.isEmpty) return true;

    // If there are any system alarms, plant is offline
    return !alarms.any((alarm) => alarm.source.toLowerCase() == 'system');
  }

  // Get system alarms only
  List<AlarmDto> get systemAlarms {
    return alarms.where((alarm) => alarm.source.toLowerCase() == 'system').toList();
  }

  // Get non-system alarms for display
  List<AlarmDto> get displayAlarms {
    return alarms.where((alarm) => alarm.source.toLowerCase() != 'system').toList();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load plant status data with alarms included
      _plantStatus = await _plantService.getPlantStatus(plantId);

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
