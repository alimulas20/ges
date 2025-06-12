class DeviceSetupDTO {
  final int deviceSetupId;
  final String deviceName;
  final String setupName;
  final String plantName;
  final int slaveNumber;
  final DateTime? warrantyExpirationDate;
  final double dailyProductionKWh;
  final double currentActivePowerKW;
  final String deviceType;
  final String softwareVersion;
  final DateTime? lastUpdateTime;
  final int pvStringCount;

  DeviceSetupDTO({
    required this.deviceSetupId,
    required this.deviceName,
    required this.setupName,
    required this.plantName,
    required this.slaveNumber,
    this.warrantyExpirationDate,
    required this.dailyProductionKWh,
    required this.currentActivePowerKW,
    required this.deviceType,
    required this.softwareVersion,
    this.lastUpdateTime,
    required this.pvStringCount,
  });

  factory DeviceSetupDTO.fromJson(Map<String, dynamic> json) {
    return DeviceSetupDTO(
      deviceSetupId: json['deviceSetupId'],
      deviceName: json['deviceName'],
      setupName: json['setupName'],
      plantName: json['plantName'],
      slaveNumber: json['slaveNumber'],
      warrantyExpirationDate: json['warrantyExpirationDate'] != null ? DateTime.parse(json['warrantyExpirationDate']) : null,
      dailyProductionKWh: json['dailyProductionKWh']?.toDouble() ?? 0.0,
      currentActivePowerKW: json['currentActivePowerKW']?.toDouble() ?? 0.0,
      deviceType: json['deviceType'],
      softwareVersion: json['softwareVersion'],
      lastUpdateTime: json['lastUpdateTime'] != null ? DateTime.parse(json['lastUpdateTime']) : null,
      pvStringCount: json['pvStringCount'],
    );
  }
}
