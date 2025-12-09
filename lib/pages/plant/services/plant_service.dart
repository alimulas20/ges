// services/api_service.dart

import 'package:dio/dio.dart';

import '../../../global/dtos/dropdown_dto.dart';
import '../../../global/managers/dio_service.dart';
import '../models/plant_dto.dart';
import '../models/plant_production_model.dart';
import '../models/plant_status_dto.dart';
import '../models/plant_with_latest_weather_dto.dart';

class PlantService {
  Future<List<PlantWithLatestWeatherDto>> getPlantswithWeather() async {
    try {
      final response = await DioService.dio.get('/plant');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PlantWithLatestWeatherDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load PV strings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load PV strings: $e');
    }
  }

  Future<PlantProductionDTO> getPlantProductionByDate(int plantId, ProductionTimePeriod timePeriod, DateTime selectedDate) async {
    try {
      final response = await DioService.dio.get('/plant/$plantId/production', queryParameters: {'timePeriod': timePeriod.index, 'selectedDate': selectedDate.toIso8601String()});

      if (response.statusCode == 200) {
        return PlantProductionDTO.fromJson(response.data);
      } else {
        throw Exception('Failed to load plant production: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load plant production: $e');
    }
  }

  Future<List<DropdownDto>> getPlantsDropdown() async {
    try {
      final response = await DioService.dio.get('/Plant/Dropdown');
      if (response.statusCode == 200) {
        return (response.data as List).map((item) => DropdownDto.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load plant list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load plant list: $e');
    }
  }

  Future<PlantStatusDto> getPlantStatus(int plantId) async {
    try {
      final response = await DioService.dio.get('/plant/$plantId/status');

      if (response.statusCode == 200) {
        return PlantStatusDto.fromJson(response.data);
      } else {
        throw Exception('Failed to load plant status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load plant status: $e');
    }
  }

  Future<PlantDto> getPlantById(int plantId) async {
    try {
      final response = await DioService.dio.get('/plant/$plantId');
      if (response.statusCode == 200) {
        return PlantDto.fromJson(response.data);
      } else {
        throw Exception('Failed to load plant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load plant: $e');
    }
  }

  Future<void> updatePlant(int plantId, PlantUpdateDto dto) async {
    try {
      await DioService.dio.put('/plant/$plantId', data: dto.toJson());
    } catch (e) {
      throw Exception('Failed to update plant: $e');
    }
  }

  Future<String?> setPlantPicture(int plantId, dynamic file) async {
    try {
      FormData formData = FormData.fromMap({'id': plantId, 'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)});
      var response = await DioService.dio.post<String>('/plant/SetPicture', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to set plant picture: $e');
    }
  }
}
