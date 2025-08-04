import '../../../global/managers/dio_service.dart';
import '../model/alarm_dto.dart';

class AlarmService {
  Future<List<AlarmDto>> getAlarms({int? plantId, int? deviceSetupId, DateTime? selectedDate, bool activeOnly = false, List<String> levels = const ['Major', 'Minor', 'Warning']}) async {
    try {
      final requestDto = GetAlarmsRequestDto(plantId: plantId, deviceSetupId: deviceSetupId, selectedDate: selectedDate, activeOnly: activeOnly, levels: levels);
      final response = await DioService.dio.post('/Alarms', data: requestDto.toJson());

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AlarmDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alarms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load alarms: $e');
    }
  }

  Future<AlarmDetailDto> getAlarmDetails(int alarmId) async {
    try {
      final response = await DioService.dio.get('/Alarms/$alarmId');

      if (response.statusCode == 200) {
        return AlarmDetailDto.fromJson(response.data);
      } else {
        throw Exception('Failed to load alarm details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load alarm details: $e');
    }
  }
}
