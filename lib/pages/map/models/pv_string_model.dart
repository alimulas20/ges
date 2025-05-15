// models/pv_string_model.dart
class PVStringModel {
  final int id;
  final String technicalName;
  final String inverterName;
  final String panelType;
  final int panelCount;
  final List<LocationSeries> locationSeries;
  final double? lastPVV;
  final double? lastPVA;
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
    this.maxPower,
  });

  double get lastPower => (lastPVV ?? 0) * (lastPVA ?? 0);

  factory PVStringModel.fromJson(Map<String, dynamic> json) {
    final lastGen = json['lastGeneration'];

    return PVStringModel(
      id: json['id'],
      technicalName: json['technicalName'],
      inverterName: json['inverterName'],
      panelType: json['panelType'],
      panelCount: json['panelCount'],
      locationSeries: (json['locationSeries'] as List<dynamic>).map((ls) => LocationSeries.fromJson(ls)).toList(),
      lastPVV: lastGen?['pvv']?.toDouble(),
      lastPVA: lastGen?['pva']?.toDouble(),
      maxPower: json['todayMaxPower']?.toDouble(),
    );
  }
}

//http://78.187.86.118:8083/UPLOAD/mistav.png
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
