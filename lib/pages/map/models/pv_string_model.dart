// models/pv_string_model.dart
class PVStringModel {
  final int id;
  final String technicalName;
  final String inverterName;
  final PanelType panelType;
  final int panelCount;
  final List<LocationSeries> locationSeries;
  final double? lastPVV;
  final double? lastPVA;
  final double? lastPower;
  final double? maxPVV;
  final double? maxPVA;
  final double? maxPower;

  PVStringModel({
    required this.id,
    required this.technicalName,
    required this.inverterName,
    required this.panelType,
    required this.panelCount,
    required this.locationSeries,
    this.lastPVV,
    this.lastPVA,
    this.lastPower,
    this.maxPVV,
    this.maxPVA,
    this.maxPower,
  });

  factory PVStringModel.fromJson(Map<String, dynamic> json) {
    final lastGen = json['lastGeneration'];
    final maxGen = json['todayMaxGeneration'];
    return PVStringModel(
      id: json['id'],
      technicalName: json['technicalName'],
      inverterName: json['inverterName'],
      panelType: PanelType.fromJson(json['panelType']),
      panelCount: json['panelCount'],
      locationSeries: (json['locationSeries'] as List<dynamic>).map((ls) => LocationSeries.fromJson(ls)).toList(),
      lastPVV: lastGen?['pvv']?.toDouble(),
      lastPVA: lastGen?['pva']?.toDouble(),
      lastPower: lastGen?['power']?.toDouble(),
      maxPVV: maxGen?['pvv']?.toDouble(),
      maxPVA: maxGen?['pva']?.toDouble(),
      maxPower: maxGen?['power']?.toDouble(),
    );
  }
}

class PanelType {
  final String brand;
  final String model;
  final double maxPower;
  final double voltageAtMaxPower;
  final double currentAtMaxPower;

  PanelType({required this.brand, required this.model, required this.maxPower, required this.voltageAtMaxPower, required this.currentAtMaxPower});

  factory PanelType.fromJson(Map<String, dynamic> json) {
    return PanelType(
      brand: json['brand'] as String,
      model: json['model'] as String,
      maxPower: json['maxPower']?.toDouble() ?? 0.0,
      voltageAtMaxPower: json['voltageAtMaxPower']?.toDouble() ?? 0.0,
      currentAtMaxPower: json['currentAtMaxPower']?.toDouble() ?? 0.0,
    );
  }

  String get displayName => '$brand $model';
  String get specs => '${maxPower}W (${voltageAtMaxPower}V/${currentAtMaxPower}A)';
}

class LocationSeries {
  final int id;
  final String name;
  final List<GeoPoint> points;

  LocationSeries({required this.id, required this.name, required this.points});

  factory LocationSeries.fromJson(Map<String, dynamic> json) {
    return LocationSeries(id: json['id'] as int, name: json['name'] as String, points: (json['points'] as List<dynamic>).map((p) => GeoPoint.fromJson(p as Map<String, dynamic>)).toList());
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;
  final int order;

  GeoPoint({required this.latitude, required this.longitude, required this.order});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(latitude: json['latitude'] as double, longitude: json['longitude'] as double, order: json['order'] as int);
  }
}
