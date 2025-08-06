// services/api_service.dart

import '../../../global/dtos/dropdown_dto.dart';
import '../../../global/managers/dio_service.dart';
import '../models/plant_production_model.dart';
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
}
