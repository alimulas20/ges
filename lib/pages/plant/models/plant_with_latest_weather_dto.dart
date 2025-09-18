import '../../alarm/model/alarm_dto.dart';
import 'weather_data_dto.dart';

class PlantWithLatestWeatherDto {
  final int id;
  final String name;
  final String plantType;
  final double totalStringCapacityKWp;
  final String address;
  final String countryOrRegion;
  final DateTime gridConnectionDate;
  final double latitude;
  final double longitude;
  final double altitude;
  final double dailyProduction;
  final WeatherDataDto? latestWeather;
  final String? plantPictureUrl;
  final List<AlarmDto>? alarms;

  // Harita için statik veriler
  final double? mapZoomLevel;
  final String? mapImageUrl;
  final double? mapTopLeftLat;
  final double? mapTopLeftLng;
  final double? mapBottomRightLat;
  final double? mapBottomRightLng;

  PlantWithLatestWeatherDto({
    required this.id,
    required this.name,
    required this.plantType,
    required this.totalStringCapacityKWp,
    required this.address,
    required this.countryOrRegion,
    required this.gridConnectionDate,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.dailyProduction,
    this.latestWeather,
    this.plantPictureUrl,
    this.alarms,
    this.mapZoomLevel,
    this.mapImageUrl,
    this.mapTopLeftLat,
    this.mapTopLeftLng,
    this.mapBottomRightLat,
    this.mapBottomRightLng,
  });

  factory PlantWithLatestWeatherDto.fromJson(Map<String, dynamic> json) {
    return PlantWithLatestWeatherDto(
      id: json['id'],
      name: json['name'],
      plantType: json['plantType'],
      totalStringCapacityKWp: json['totalStringCapacityKWp']?.toDouble() ?? 0.0,
      address: json['address'],
      countryOrRegion: json['countryOrRegion'],
      gridConnectionDate: DateTime.parse(json['gridConnectionDate']),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      altitude: json['altitude']?.toDouble() ?? 0.0,
      dailyProduction: json['dailyProduction']?.toDouble() ?? 0.0,
      latestWeather: json['latestWeather'] != null ? WeatherDataDto.fromJson(json['latestWeather']) : null,
      plantPictureUrl: json['plantPictureUrl'],
      alarms: json['alarms'] != null ? (json['alarms'] as List).map((e) => AlarmDto.fromJson(e)).toList() : null,
      mapZoomLevel: json['mapZoomLevel']?.toDouble(),
      mapImageUrl: json['mapImageUrl'],
      mapTopLeftLat: json['mapTopLeftLat']?.toDouble(),
      mapTopLeftLng: json['mapTopLeftLng']?.toDouble(),
      mapBottomRightLat: json['mapBottomRightLat']?.toDouble(),
      mapBottomRightLng: json['mapBottomRightLng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantType': plantType,
      'totalStringCapacityKWp': totalStringCapacityKWp,
      'address': address,
      'countryOrRegion': countryOrRegion,
      'gridConnectionDate': gridConnectionDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'dailyProduction': dailyProduction,
      'latestWeather': latestWeather?.toJson(),
      'plantPictureUrl': plantPictureUrl,
      'alarms': alarms?.map((e) => e.toJson()).toList(),
      'mapZoomLevel': mapZoomLevel,
      'mapImageUrl': mapImageUrl,
      'mapTopLeftLat': mapTopLeftLat,
      'mapTopLeftLng': mapTopLeftLng,
      'mapBottomRightLat': mapBottomRightLat,
      'mapBottomRightLng': mapBottomRightLng,
    };
  }
}
