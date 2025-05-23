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
  final WeatherDataDto? latestWeather;

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
    this.latestWeather,
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
      latestWeather: json['latestWeather'] != null ? WeatherDataDto.fromJson(json['latestWeather']) : null,
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
      'latestWeather': latestWeather?.toJson(),
    };
  }
}
