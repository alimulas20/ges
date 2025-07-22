// viewmodels/device_history_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceHistoryViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  final int deviceSetupId;

  List<InverterAttributeDTO> _attributes = [];
  final Set<String> _selectedAttributes = {};
  String? _errorMessage;
  bool _isLoading = false;

  DeviceHistoryViewModel(this._service, this.deviceSetupId);

  List<InverterAttributeDTO> get attributes => _attributes;
  Set<String> get selectedAttributes => _selectedAttributes;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchAttributes() async {
    try {
      _isLoading = true;
      notifyListeners();

      _attributes = await _service.getInverterAttributes(deviceSetupId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAttribute(String key) {
    _selectedAttributes.add(key);
    notifyListeners();
    // Here you would also fetch the historical data for this attribute
  }

  void deselectAttribute(String key) {
    _selectedAttributes.remove(key);
    notifyListeners();
  }
}
