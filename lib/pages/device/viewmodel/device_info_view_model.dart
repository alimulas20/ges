// viewmodels/device_info_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceInfoViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  final int deviceSetupId;

  DeviceInfoDTO? _deviceInfo;
  String? _errorMessage;
  bool _isLoading = false;
  DeviceInfoViewModel(this._service, this.deviceSetupId);

  DeviceInfoDTO? get deviceInfo => _deviceInfo;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchDeviceInfo() async {
    try {
      _isLoading = true;
      notifyListeners();

      _deviceInfo = await _service.getDeviceInfo(deviceSetupId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
