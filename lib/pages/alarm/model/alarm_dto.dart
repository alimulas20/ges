import 'dart:convert';

class AlarmDto {
  final int id;
  final String level;
  final String name;
  final String plantName;
  final String? deviceSetupName;
  final DateTime occuredAt;
  final DateTime? clearedAt;

  AlarmDto({required this.id, required this.level, required this.name, required this.plantName, this.deviceSetupName, required this.occuredAt, this.clearedAt});

  factory AlarmDto.fromJson(Map<String, dynamic> json) {
    return AlarmDto(
      id: json['id'],
      level: json['level'],
      name: json['name'],
      plantName: json['plantName'],
      deviceSetupName: json['deviceSetupName'],
      occuredAt: DateTime.parse(json['occuredAt']),
      clearedAt: json['clearedAt'] != null ? DateTime.parse(json['clearedAt']) : null,
    );
  }
}

class AlarmDetailDto extends AlarmDto {
  final String alarmCode;
  final String source;
  final String description;

  AlarmDetailDto({
    required super.id,
    required super.level,
    required super.name,
    required super.plantName,
    super.deviceSetupName,
    required super.occuredAt,
    super.clearedAt,
    required this.alarmCode,
    required this.source,
    required this.description,
  });

  factory AlarmDetailDto.fromJson(Map<String, dynamic> json) {
    return AlarmDetailDto(
      id: json['id'],
      level: json['level'],
      name: json['name'],
      plantName: json['plantName'],
      deviceSetupName: json['deviceSetupName'],
      occuredAt: DateTime.parse(json['occuredAt']),
      clearedAt: json['clearedAt'] != null ? DateTime.parse(json['clearedAt']) : null,
      alarmCode: json['alarmCode'],
      source: json['source'],
      description: json['description'],
    );
  }
}

class PlantDto {
  final int id;
  final String name;

  PlantDto({required this.id, required this.name});
  factory PlantDto.fromJson(Map<String, dynamic> json) {
    return PlantDto(id: json['id'], name: json['name']);
  }
}

class DeviceDto {
  final int id;
  final String name;
  final int plantId;

  DeviceDto({required this.id, required this.name, required this.plantId});
}

class GetAlarmsRequestDto {
  final int? plantId;
  final int? deviceSetupId;
  final DateTime? selectedDate;
  final bool activeOnly;
  final List<String> levels;

  GetAlarmsRequestDto({this.plantId, this.deviceSetupId, this.selectedDate, this.activeOnly = false, this.levels = const ['Major', 'Minor', 'Warning']});

  Map<String, dynamic> toJson() => {'plantId': plantId, 'deviceSetupId': deviceSetupId, 'selectedDate': selectedDate?.toIso8601String(), 'activeOnly': activeOnly, 'levels': levels};
}
