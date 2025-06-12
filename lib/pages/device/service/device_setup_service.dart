import 'package:smart_ges_360/global/managers/dio_service.dart';

import '../model/device_setup_dto.dart';

class DeviceSetupService {
  Future<List<DeviceSetupDTO>> getDeviceSetups() async {
    try {
      final response = await DioService.dio.get('/DeviceSetup');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => DeviceSetupDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load device setups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load device setups: $e');
    }
  }
}
