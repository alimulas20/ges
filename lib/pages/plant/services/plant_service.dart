// services/api_service.dart
import 'package:smart_ges_360/global/managers/dio_service.dart';
import 'package:smart_ges_360/pages/plant/models/plant_with_latest_weather_dto.dart';

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
}
