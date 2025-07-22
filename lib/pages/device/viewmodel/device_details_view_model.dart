// viewmodels/device_details_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceDetailsViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  final int deviceSetupId;

  DeviceDetailsDTO? _deviceDetails;
  String? _errorMessage;
  bool _isLoading = false;

  DeviceDetailsViewModel(this._service, this.deviceSetupId);

  DeviceDetailsDTO? get deviceDetails => _deviceDetails;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchDeviceDetails() async {
    try {
      _isLoading = true;
      notifyListeners();

      _deviceDetails = await _service.getDeviceDetails(deviceSetupId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
