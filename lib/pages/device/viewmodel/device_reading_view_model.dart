// viewmodels/device_readings_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceReadingsViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  final int deviceSetupId;

  DeviceReadingsDTO? _deviceReadings;
  String? _errorMessage;
  bool _isLoading = false;

  DeviceReadingsViewModel(this._service, this.deviceSetupId);

  DeviceReadingsDTO? get deviceReadings => _deviceReadings;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchDeviceReadings() async {
    try {
      _isLoading = true;
      notifyListeners();

      _deviceReadings = await _service.getDeviceReadings(deviceSetupId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
