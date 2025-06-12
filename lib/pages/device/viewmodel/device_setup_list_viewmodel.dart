import 'package:flutter/material.dart';

import '../model/device_setup_dto.dart';
import '../service/device_setup_service.dart';

class DeviceSetupListViewModel with ChangeNotifier {
  final DeviceSetupService _deviceSetupService;

  List<DeviceSetupDTO> _deviceSetups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DeviceSetupDTO> get deviceSetups => _deviceSetups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DeviceSetupListViewModel(this._deviceSetupService);

  Future<void> fetchDeviceSetups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deviceSetups = await _deviceSetupService.getDeviceSetups();
      _errorMessage = null;
    } catch (e) {
      _deviceSetups = [];
      _errorMessage = 'Failed to load device setups: ${e.toString()}';
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
