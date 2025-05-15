// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pv_string_model.dart';

class ApiService {
  final String _baseUrl = 'http://192.168.1.57:5002/api';

  Future<List<PVStringModel>> getPVStringsWithGeneration(int plantId) async {
    final response = await http.get(Uri.parse('$_baseUrl/PVStrings/generation/$plantId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      var list = data.map((json) => PVStringModel.fromJson(json)).toList();
      return list.where((x) => x.locationSeries.isNotEmpty).toList();
    } else {
      throw Exception('Failed to load PV strings');
    }
  }
}
