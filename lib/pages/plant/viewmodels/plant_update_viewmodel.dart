// plant_update_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/plant_dto.dart';
import '../services/plant_service.dart';

class PlantUpdateViewModel with ChangeNotifier {
  final PlantService _service;

  PlantUpdateViewModel(this._service);

  bool _isLoading = false;
  String? _error;
  PlantDto? _currentPlant;

  bool get isLoading => _isLoading;
  String? get error => _error;
  PlantDto? get currentPlant => _currentPlant;

  Future<void> loadPlant(int plantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPlant = await _service.getPlantById(plantId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlant(int plantId, PlantUpdateDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updatePlant(plantId, dto);
      await loadPlant(plantId); // Reload plant after update
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> setPlantPicture(int plantId, XFile file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var url = await _service.setPlantPicture(plantId, file);
      await loadPlant(plantId); // Reload plant after picture update
      return url ?? "";
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

