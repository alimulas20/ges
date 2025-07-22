// models/device_setup_with_reading_dto.dart
class DeviceSetupWithReadingDTO {
  final int deviceSetupId;
  final String deviceName;
  final String setupName;
  final String plantName;
  final int slaveNumber;
  final DateTime? warrantyExpirationDate;
  final String deviceType;
  final String softwareVersion;
  final InverterReadingDTO? latestReading;

  DeviceSetupWithReadingDTO({
    required this.deviceSetupId,
    required this.deviceName,
    required this.setupName,
    required this.plantName,
    required this.slaveNumber,
    this.warrantyExpirationDate,
    required this.deviceType,
    required this.softwareVersion,
    this.latestReading,
  });

  factory DeviceSetupWithReadingDTO.fromJson(Map<String, dynamic> json) {
    return DeviceSetupWithReadingDTO(
      deviceSetupId: json['deviceSetupId'],
      deviceName: json['deviceName'],
      setupName: json['setupName'],
      plantName: json['plantName'],
      slaveNumber: json['slaveNumber'],
      warrantyExpirationDate: json['warrantyExpirationDate'] != null ? DateTime.parse(json['warrantyExpirationDate']) : null,
      deviceType: json['deviceType'],
      softwareVersion: json['softwareVersion'],
      latestReading: json['latestReading'] != null ? InverterReadingDTO.fromJson(json['latestReading']) : null,
    );
  }
}

// models/inverter_reading_dto.dart
class InverterReadingDTO {
  final DateTime createdDate;
  final double activePower;
  final double yieldToday;
  final double totalYield;
  final double gridFrequency;
  final double internalTemperature;

  InverterReadingDTO({required this.createdDate, required this.activePower, required this.yieldToday, required this.totalYield, required this.gridFrequency, required this.internalTemperature});

  factory InverterReadingDTO.fromJson(Map<String, dynamic> json) {
    return InverterReadingDTO(
      createdDate: DateTime.parse(json['createdDate']),
      activePower: json['activePower'].toDouble(),
      yieldToday: json['yieldToday'].toDouble(),
      totalYield: json['totalYield'].toDouble(),
      gridFrequency: json['gridFrequency'].toDouble(),
      internalTemperature: json['internalTemperature'].toDouble(),
    );
  }
}

// models/device_details_dto.dart
class DeviceDetailsDTO {
  final int deviceSetupId;
  final String deviceName;
  final String setupName;
  final String plantName;
  final int slaveNumber;
  final DateTime? warrantyExpirationDate;
  final String deviceType;
  final String softwareVersion;
  final InverterReadingDTO? latestReading;
  final PVGenerationDTO? pvGenerations;

  DeviceDetailsDTO({
    required this.deviceSetupId,
    required this.deviceName,
    required this.setupName,
    required this.plantName,
    required this.slaveNumber,
    this.warrantyExpirationDate,
    required this.deviceType,
    required this.softwareVersion,
    this.latestReading,
    this.pvGenerations,
  });

  factory DeviceDetailsDTO.fromJson(Map<String, dynamic> json) {
    return DeviceDetailsDTO(
      deviceSetupId: json['deviceSetupId'],
      deviceName: json['deviceName'],
      setupName: json['setupName'],
      plantName: json['plantName'],
      slaveNumber: json['slaveNumber'],
      warrantyExpirationDate: json['warrantyExpirationDate'] != null ? DateTime.parse(json['warrantyExpirationDate']) : null,
      deviceType: json['deviceType'],
      softwareVersion: json['softwareVersion'],
      latestReading: json['latestReading'] != null ? InverterReadingDTO.fromJson(json['latestReading']) : null,
      pvGenerations: json['pvGenerations'] != null ? PVGenerationDTO.fromJson(json['pvGenerations']) : null,
    );
  }
}

// models/pv_generation_dto.dart
class PVGenerationDTO {
  final String pvStringName;
  final double voltage;
  final double current;
  final double power;
  final DateTime createdDate;

  PVGenerationDTO({required this.pvStringName, required this.voltage, required this.current, required this.power, required this.createdDate});

  factory PVGenerationDTO.fromJson(Map<String, dynamic> json) {
    return PVGenerationDTO(
      pvStringName: json['pvStringName'],
      voltage: json['voltage'].toDouble(),
      current: json['current'].toDouble(),
      power: json['power'].toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

// models/pv_string_info_dto.dart
class PVStringInfoDTO {
  final int id;
  final String name;
  final int panelCount;
  final String panelType;

  PVStringInfoDTO({required this.id, required this.name, required this.panelCount, required this.panelType});

  factory PVStringInfoDTO.fromJson(Map<String, dynamic> json) {
    return PVStringInfoDTO(id: json['id'], name: json['name'], panelCount: json['panelCount'], panelType: json['panelType']);
  }
}

// models/inverter_attribute_dto.dart
class InverterAttributeDTO {
  final String key;
  final String name;
  final String unit;
  final String description;

  InverterAttributeDTO({required this.key, required this.name, required this.unit, required this.description});

  factory InverterAttributeDTO.fromJson(Map<String, dynamic> json) {
    return InverterAttributeDTO(key: json['key'], name: json['name'], unit: json['unit'], description: json['description']);
  }
}

class PVComparisonDTO {
  final int deviceSetupId;
  final DateTime date;
  final PVMeasurementType measurementType;
  final List<PVComparisonDataPointDTO> dataPoints;

  PVComparisonDTO({required this.deviceSetupId, required this.date, required this.measurementType, required this.dataPoints});

  factory PVComparisonDTO.fromJson(Map<String, dynamic> json) {
    return PVComparisonDTO(
      deviceSetupId: json['deviceSetupId'],
      date: DateTime.parse(json['date']),
      measurementType: PVMeasurementType.values[json['measurementType']],
      dataPoints: (json['dataPoints'] as List).map((e) => PVComparisonDataPointDTO.fromJson(e)).toList(),
    );
  }
}

class PVComparisonDataPointDTO {
  final DateTime timestamp;
  final Map<String, double> values; // PVStringName -> Value

  PVComparisonDataPointDTO({required this.timestamp, required this.values});

  factory PVComparisonDataPointDTO.fromJson(Map<String, dynamic> json) {
    return PVComparisonDataPointDTO(timestamp: DateTime.parse(json['timestamp']), values: (json['values'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toDouble())));
  }
}

enum PVMeasurementType { Voltage, Current, Power }

extension PVMeasurementTypeExtension on PVMeasurementType {
  int get value {
    switch (this) {
      case PVMeasurementType.Voltage:
        return 0;
      case PVMeasurementType.Current:
        return 1;
      case PVMeasurementType.Power:
        return 2;
    }
  }
}

// model/inverter_comparison_dto.dart
class InverterComparisonDTO {
  final int deviceSetupId;
  final DateTime date;
  final List<InverterComparisonDataPointDTO> dataPoints;

  InverterComparisonDTO({required this.deviceSetupId, required this.date, required this.dataPoints});

  factory InverterComparisonDTO.fromJson(Map<String, dynamic> json) {
    return InverterComparisonDTO(
      deviceSetupId: json['deviceSetupId'],
      date: DateTime.parse(json['date']),
      dataPoints: (json['dataPoints'] as List).map((point) => InverterComparisonDataPointDTO.fromJson(point)).toList(),
    );
  }
}

class InverterComparisonDataPointDTO {
  final DateTime timestamp;
  final Map<String, double> values;

  InverterComparisonDataPointDTO({required this.timestamp, required this.values});

  factory InverterComparisonDataPointDTO.fromJson(Map<String, dynamic> json) {
    return InverterComparisonDataPointDTO(timestamp: DateTime.parse(json['timestamp']), values: (json['values'] as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toDouble())));
  }
}
