// viewmodels/device_setup_list_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceSetupListViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  List<DeviceSetupWithReadingDTO> _devices = [];
  String? _errorMessage;
  bool _isLoading = false;

  DeviceSetupListViewModel(this._service);

  List<DeviceSetupWithReadingDTO> get devices => _devices;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchDevices() async {
    try {
      _isLoading = true;
      notifyListeners();

      _devices = await _service.getUserDeviceSetups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
