// services/api_service.dart
import 'package:smart_ges_360/global/managers/dio_service.dart';
import 'package:smart_ges_360/pages/plant/models/plant_with_latest_weather_dto.dart';

import '../models/plant_production_model.dart';

class PlantService {
  Future<List<PlantWithLatestWeatherDto>> getPlants() async {
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
}
