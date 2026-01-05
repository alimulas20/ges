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

  Future<PlantPredictionResponse> getPlantProductionPrediction(int plantId, ProductionTimePeriod timePeriod, DateTime selectedDate) async {
    try {
      final requestData = {'plantId': plantId, 'date': selectedDate.toIso8601String()};

      final response = await DioService.dio.post('/Prediction/predict', data: requestData);

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> hourlyData = responseData['hourly'] ?? [];
        final totalAcEnergyKwh = (responseData['totalAcEnergyKwh'] ?? 0.0).toDouble();

        // HourlyPredictionDto'dan ProductionDataPointDTO'ya dönüştür
        final dataPoints =
            hourlyData.map((json) {
              // DateTimeOffset string'ini parse et (ISO8601 formatında)
              final timestampStr = json['timestamp'] as String;
              DateTime timestamp;

              // DateTimeOffset formatını parse et (örn: "2024-01-01T10:00:00+03:00" veya "2024-01-01T10:00:00Z")
              if (timestampStr.contains('+') || timestampStr.contains('Z')) {
                // UTC'ye çevir
                timestamp = DateTime.parse(timestampStr).toLocal();
              } else {
                timestamp = DateTime.parse(timestampStr);
              }

              final acPowerKw = (json['acPowerKw'] ?? 0.0).toDouble();

              // Time label oluştur (saat formatında)
              final timeLabel = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

              return ProductionDataPointDTO(timestamp: timestamp, totalProduction: acPowerKw, timeLabel: timeLabel);
            }).toList();

        return PlantPredictionResponse(dataPoints: dataPoints, totalAcEnergyKwh: totalAcEnergyKwh);
      } else {
        throw Exception('Failed to load plant production prediction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load plant production prediction: $e');
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
