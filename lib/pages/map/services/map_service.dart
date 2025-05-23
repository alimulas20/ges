// services/api_service.dart
import 'package:smart_ges_360/global/managers/dio_service.dart';
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
}
