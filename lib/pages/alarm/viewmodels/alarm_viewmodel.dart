import 'package:flutter/material.dart';

import '../../../global/dtos/dropdown_dto.dart';
import '../../../global/utils/alert_utils.dart';
import '../../device/service/device_setup_service.dart';
import '../../plant/services/plant_service.dart';
import '../model/alarm_dto.dart';
import '../service/alarm_service.dart';

class AlarmsViewModel with ChangeNotifier {
  final AlarmService _service;
  final PlantService _plantService;
  final DeviceSetupService _deviceSetupService;
  List<AlarmDto> _alarms = [];
  List<DropdownDto> _plants = [];
  List<DropdownWithParentDto> _devices = [];
  String? _errorMessage;
  bool _isLoading = false;

  AlarmsViewModel(this._service, this._plantService, this._deviceSetupService);

  List<AlarmDto> get alarms => _alarms;
  List<DropdownDto> get plants => _plants;
  List<DropdownWithParentDto> get devices => _devices;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchAlarms({int? plantId, int? deviceSetupId, DateTime? selectedDate, bool activeOnly = false, List<String> levels = const ['Major', 'Minor', 'Warning']}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load plants if not already loaded
      if (_plants.isEmpty) {
        _plants = await _plantService.getPlantsDropdown();
      }
      // Load devices if not already loaded or if plantId has changed
      if (_devices.isEmpty || ((_devices.isEmpty || _devices.first.parentId != plantId))) {
        _devices = await _deviceSetupService.getDevicesDropdown();
      }
      _alarms = await _service.getAlarms(plantId: plantId, deviceSetupId: deviceSetupId, selectedDate: selectedDate, activeOnly: activeOnly, levels: levels);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = AlertUtils.formatErrorMessage(e);
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AlarmDetailDto> getAlarmDetails(int alarmId) async {
    return await _service.getAlarmDetails(alarmId);
  }
}
