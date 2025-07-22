// viewmodels/device_history_view_model.dart
import 'package:flutter/material.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';

class DeviceHistoryViewModel with ChangeNotifier {
  final DeviceSetupService _service;
  final int deviceSetupId;

  // Inverter Attributes
  List<InverterAttributeDTO> _attributes = [];
  String? _selectedAttribute;
  DateTime _selectedDate = DateTime.now();

  // PV Strings
  List<PVStringInfoDTO> _pvStrings = [];
  List<int> _selectedPvStringIds = [];
  PVMeasurementType _selectedMeasurementType = PVMeasurementType.Power;

  // Data
  dynamic _inverterData; // Grafik verisi burada olacak
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
  bool get isLoadingPvComparison => _isLoadingPvComparison;
  bool get isLoadingInverterData => _isLoadingInverterData;
  // Getters
  List<InverterAttributeDTO> get attributes => _attributes;
  String? get selectedAttribute => _selectedAttribute;
  DateTime get selectedDate => _selectedDate;

  List<PVStringInfoDTO> get pvStrings => _pvStrings;
  List<int> get selectedPvStringIds => _selectedPvStringIds;
  PVMeasurementType get selectedMeasurementType => _selectedMeasurementType;

  dynamic get inverterData => _inverterData;
  PVComparisonDTO? get pvComparisonData => _pvComparisonData;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoadingAttributes || _isLoadingPvStrings || _isLoadingInverterData || _isLoadingPvComparison;

  Future<void> _initData() async {
    await Future.wait([_fetchAttributes(), _fetchPvStrings()]);

    // Varsayılan seçimleri yap
    if (_attributes.isNotEmpty) {
      _selectedAttribute = _attributes.first.key;
      _fetchInverterData();
    }

    if (_pvStrings.isNotEmpty) {
      _selectedPvStringIds = [_pvStrings.first.id];
      _fetchPvComparisonData();
    }
  }

  Future<void> _fetchAttributes() async {
    try {
      _isLoadingAttributes = true;
      notifyListeners();

      _attributes = await _service.getInverterAttributes(deviceSetupId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingPvStrings = false;
      notifyListeners();
    }
  }

  Future<void> _fetchInverterData() async {
    if (_selectedAttribute == null) return;

    try {
      _isLoadingInverterData = true;
      notifyListeners();

      // Burada API'den veri çekme işlemi olacak
      // _inverterData = await _service.getInverterHistoryData(...);
      // Şimdilik mock data koyalım
      await Future.delayed(Duration(seconds: 1));
      _inverterData = {'labels': List.generate(24, (i) => '$i:00'), 'data': List.generate(24, (i) => 100 + (i * 10) % 100)};
    } catch (e) {
      _errorMessage = e.toString();
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

      _pvComparisonData = await _service.getPVGenerationComparisonData(deviceSetupId, _selectedDate, _selectedMeasurementType, _selectedPvStringIds);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingPvComparison = false;
      notifyListeners();
    }
  }

  void setSelectedAttribute(String? attributeKey) {
    _selectedAttribute = attributeKey;
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
