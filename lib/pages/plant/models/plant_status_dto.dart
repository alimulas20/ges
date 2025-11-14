import '../../alarm/model/alarm_dto.dart';

class PlantStatusDto {
  final int plantId;
  final String plantName;
  final double totalStringCapacityKWp;
  final double inverterNominalPower;
  final double todayProduction;
  final double totalProduction;
  final double currentPVGeneration;
  final List<AlarmDto> alarms;

  PlantStatusDto({
    required this.plantId,
    required this.plantName,
    required this.totalStringCapacityKWp,
    required this.inverterNominalPower,
    required this.todayProduction,
    required this.totalProduction,
    required this.currentPVGeneration,
    required this.alarms,
  });

  factory PlantStatusDto.fromJson(Map<String, dynamic> json) {
    return PlantStatusDto(
      plantId: json['plantId'] ?? 0,
      plantName: json['plantName'] ?? '',
      totalStringCapacityKWp: (json['totalStringCapacityKWp'] ?? 0).toDouble(),
      inverterNominalPower: (json['inverterNominalPower'] ?? 0).toDouble(),
      todayProduction: (json['todayProduction'] ?? 0).toDouble(),
      totalProduction: (json['totalProduction'] ?? 0).toDouble(),
      currentPVGeneration: (json['currentPVGeneration'] ?? 0).toDouble(),
      alarms: json['alarms'] != null ? (json['alarms'] as List).map((e) => AlarmDto.fromJson(e)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantId': plantId,
      'plantName': plantName,
      'totalStringCapacityKWp': totalStringCapacityKWp,
      'inverterNominalPower': inverterNominalPower,
      'todayProduction': todayProduction,
      'totalProduction': totalProduction,
      'currentPVGeneration': currentPVGeneration,
      'alarms': alarms.map((e) => e.toJson()).toList(),
    };
  }
}
