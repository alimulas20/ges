class AlarmDto {
  final int id;
  final int deviceSetupId;
  final DateTime occuredAt;
  final DateTime? clearedAt;
  final String source;
  final int? alarmDefinitionId;
  final String? alarmId;
  final String? alarmName;
  final String? alarmDescription;
  final String? level;
  final String? name;
  final String? plantName;
  final String? deviceSetupName;

  AlarmDto({
    required this.id,
    required this.deviceSetupId,
    required this.occuredAt,
    this.clearedAt,
    required this.source,
    this.alarmDefinitionId,
    this.alarmId,
    this.alarmName,
    this.alarmDescription,
    this.level,
    this.name,
    this.plantName,
    this.deviceSetupName,
  });

  factory AlarmDto.fromJson(Map<String, dynamic> json) {
    return AlarmDto(
      id: json['id'],
      deviceSetupId: json['deviceSetupId'],
      occuredAt: DateTime.parse(json['occuredAt']),
      clearedAt: json['clearedAt'] != null ? DateTime.parse(json['clearedAt']) : null,
      source: json['source'] ?? '',
      alarmDefinitionId: json['alarmDefinitionId'],
      alarmId: json['alarmId'],
      alarmName: json['alarmName'],
      alarmDescription: json['alarmDescription'],
      level: json['level'],
      name: json['name'],
      plantName: json['plantName'],
      deviceSetupName: json['deviceSetupName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceSetupId': deviceSetupId,
      'occuredAt': occuredAt.toIso8601String(),
      'clearedAt': clearedAt?.toIso8601String(),
      'source': source,
      'alarmDefinitionId': alarmDefinitionId,
      'alarmId': alarmId,
      'alarmName': alarmName,
      'alarmDescription': alarmDescription,
      'level': level,
      'name': name,
      'plantName': plantName,
      'deviceSetupName': deviceSetupName,
    };
  }
}

class AlarmDetailDto extends AlarmDto {
  final String alarmCode;
  final String description;

  AlarmDetailDto({
    required super.id,
    required super.deviceSetupId,
    required super.occuredAt,
    super.clearedAt,
    required super.source,
    super.alarmDefinitionId,
    super.alarmId,
    super.alarmName,
    super.alarmDescription,
    super.level,
    super.name,
    super.plantName,
    super.deviceSetupName,
    required this.alarmCode,
    required this.description,
  });

  factory AlarmDetailDto.fromJson(Map<String, dynamic> json) {
    return AlarmDetailDto(
      id: json['id'],
      deviceSetupId: json['deviceSetupId'],
      occuredAt: DateTime.parse(json['occuredAt']),
      clearedAt: json['clearedAt'] != null ? DateTime.parse(json['clearedAt']) : null,
      source: json['source'] ?? '',
      alarmDefinitionId: json['alarmDefinitionId'],
      alarmId: json['alarmId'],
      alarmName: json['alarmName'],
      alarmDescription: json['alarmDescription'],
      level: json['level'],
      name: json['name'],
      plantName: json['plantName'],
      deviceSetupName: json['deviceSetupName'],
      alarmCode: json['alarmCode'] ?? '',
      description: json['description'] ?? '',
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
