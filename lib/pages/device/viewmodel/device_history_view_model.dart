// viewmodels/device_history_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceHistoryViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  final int deviceSetupId;

  // Inverter Attributes
  List<InverterAttributeDTO> _attributes = [];
  List<String> _selectedAttributeKeys = [];
  DateTime _selectedDate = DateTime.now();

  // PV Strings
  List<PVStringInfoDTO> _pvStrings = [];
  List<int> _selectedPvStringIds = [];
  PVMeasurementType _selectedMeasurementType = PVMeasurementType.Power;

  // Data
  InverterComparisonDTO? _inverterComparisonData;
  PVComparisonDTO? _pvComparisonData;

  // States
  String? _errorMessage;
  bool _isLoadingAttributes = false;
  bool _isLoadingPvStrings = false;
  bool _isLoadingInverterData = false;
  bool _isLoadingPvComparison = false;

  DeviceHistoryViewModel(this._service, this.deviceSetupId) {
    _initData();
  }

  // Getters
  List<InverterAttributeDTO> get attributes => _attributes;
  List<String> get selectedAttributeKeys => _selectedAttributeKeys;
  DateTime get selectedDate => _selectedDate;

  List<PVStringInfoDTO> get pvStrings => _pvStrings;
  List<int> get selectedPvStringIds => _selectedPvStringIds;
  PVMeasurementType get selectedMeasurementType => _selectedMeasurementType;

  InverterComparisonDTO? get inverterComparisonData => _inverterComparisonData;
  PVComparisonDTO? get pvComparisonData => _pvComparisonData;

  bool get isLoadingInverterData => _isLoadingInverterData;
  bool get isLoadingPvComparison => _isLoadingPvComparison;
  bool get isLoading => _isLoadingAttributes || _isLoadingPvStrings || _isLoadingInverterData || _isLoadingPvComparison;
  String? get errorMessage => _errorMessage;

  Future<void> _initData() async {
    await _fetchAttributes();
    await _fetchPvStrings();
  }

  Future<void> _fetchAttributes() async {
    try {
      _isLoadingAttributes = true;
      notifyListeners();

      _attributes = await _service.getInverterAttributes(deviceSetupId);
      if (_attributes.isNotEmpty) {
        _selectedAttributeKeys = [_attributes.first.key];
        await _fetchInverterData();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Özellikler alınamadı: ${e.toString()}';
    } finally {
      _isLoadingAttributes = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPvStrings() async {
    try {
      _isLoadingPvStrings = true;
      notifyListeners();

      _pvStrings = await _service.getDevicePVStrings(deviceSetupId);
      if (_pvStrings.isNotEmpty) {
        _selectedPvStringIds = [_pvStrings.first.id];
        await _fetchPvComparisonData();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'PV Stringleri alınamadı: ${e.toString()}';
    } finally {
      _isLoadingPvStrings = false;
      notifyListeners();
    }
  }

  Future<void> _fetchInverterData() async {
    if (_selectedAttributeKeys.isEmpty) return;

    try {
      _isLoadingInverterData = true;
      notifyListeners();

      _inverterComparisonData = await _service.getInverterHistoryData(deviceSetupId, _selectedDate, _selectedAttributeKeys);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Inverter verisi alınamadı: ${e.toString()}';
    } finally {
      _isLoadingInverterData = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPvComparisonData() async {
    if (_selectedPvStringIds.isEmpty) return;

    try {
      _isLoadingPvComparison = true;
      notifyListeners();

      final rawData = await _service.getPVGenerationComparisonData(deviceSetupId, _selectedDate, _selectedMeasurementType, _selectedPvStringIds);

      // Process the data to ensure it contains only selected PV strings
      final selectedPvStringNames = _pvStrings.where((pv) => _selectedPvStringIds.contains(pv.id)).map((pv) => pv.name).toList();

      final processedDataPoints =
          rawData.dataPoints.map((point) {
            final filteredValues = <String, double>{};
            point.values.forEach((key, value) {
              if (selectedPvStringNames.contains(key)) {
                filteredValues[key] = value;
              }
            });
            return PVComparisonDataPointDTO(timestamp: point.timestamp, values: filteredValues);
          }).toList();

      _pvComparisonData = PVComparisonDTO(deviceSetupId: rawData.deviceSetupId, date: rawData.date, measurementType: rawData.measurementType, dataPoints: processedDataPoints);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'PV Karşılaştırma verisi alınamadı: ${e.toString()}';
    } finally {
      _isLoadingPvComparison = false;
      notifyListeners();
    }
  }

  void setSelectedAttributeKeys(List<String> keys) {
    _selectedAttributeKeys = keys;
    _fetchInverterData();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _fetchInverterData();
    _fetchPvComparisonData();
  }

  void setSelectedMeasurementType(PVMeasurementType type) {
    _selectedMeasurementType = type;
    _fetchPvComparisonData();
  }

  void setSelectedPvStrings(List<int> ids) {
    _selectedPvStringIds = ids;
    _fetchPvComparisonData();
  }
}
