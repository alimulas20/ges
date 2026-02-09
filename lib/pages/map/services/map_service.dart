// services/api_service.dart
import '../../../global/managers/dio_service.dart';
import '../models/pv_string_model.dart';

class MapService {
  Future<List<PVStringModel>> getPVStringsWithGeneration(int plantId) async {
    try {
      final response = await DioService.dio.get('/PVStrings/generation/$plantId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        var list = data.map((json) => PVStringModel.fromJson(json)).toList();
        return list.where((x) => x.locationSeries.isNotEmpty).toList();
      } else {
        throw Exception('Failed to load PV strings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load PV strings: $e');
    }
  }

  Future<void> addLocationSeries(int pvStringId, String name, List<Map<String, dynamic>> points) async {
    try {
      final response = await DioService.dio.post('/PVStrings/$pvStringId/locationseries', data: {'name': name, 'points': points});

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to add location series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add location series: $e');
    }
  }

  Future<void> updateLocationSeries(int locationSeriesId, String name, List<Map<String, dynamic>> points) async {
    try {
      final response = await DioService.dio.put('/PVStrings/locationseries/$locationSeriesId', data: {'name': name, 'points': points});

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to update location series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update location series: $e');
    }
  }

  Future<void> deleteLocationSeries(int locationSeriesId) async {
    try {
      final response = await DioService.dio.delete('/PVStrings/locationseries/$locationSeriesId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete location series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete location series: $e');
    }
  }
}
