// services/device_setup_service.dart
import 'package:smart_ges_360/global/managers/dio_service.dart';

import '../model/device_setup_with_reading_dto.dart';

class DeviceSetupService {
  Future<List<DeviceSetupWithReadingDTO>> getUserDeviceSetups() async {
    try {
      final response = await DioService.dio.get('/DeviceSetup/user');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => DeviceSetupWithReadingDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load device setups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load device setups: $e');
    }
  }

  Future<DeviceDetailsDTO> getDeviceDetails(int deviceSetupId) async {
    try {
      final response = await DioService.dio.get('/DeviceSetup/$deviceSetupId/details');

      if (response.statusCode == 200) {
        return DeviceDetailsDTO.fromJson(response.data);
      } else {
        throw Exception('Failed to load device details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load device details: $e');
    }
  }

  Future<List<PVStringInfoDTO>> getDevicePVStrings(int deviceSetupId) async {
    try {
      final response = await DioService.dio.get('/DeviceSetup/$deviceSetupId/pv-strings');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PVStringInfoDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load PV strings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load PV strings: $e');
    }
  }

  Future<List<InverterAttributeDTO>> getInverterAttributes(int deviceSetupId) async {
    try {
      final response = await DioService.dio.get('/DeviceSetup/$deviceSetupId/attributes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InverterAttributeDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load inverter attributes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load inverter attributes: $e');
    }
  }
}
