class WeatherDataDto {
  final double temperature;
  final double windSpeed;
  final double humidity;
  final double cloudCover;
  final DateTime measurementTime;
  final String weatherDescription;
  final int weatherCode; // Add this line

  WeatherDataDto({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.cloudCover,
    required this.measurementTime,
    required this.weatherDescription,
    required this.weatherCode, // Add this line
  });

  factory WeatherDataDto.fromJson(Map<String, dynamic> json) {
    return WeatherDataDto(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      cloudCover: json['cloudCover']?.toDouble() ?? 0.0,
      measurementTime: DateTime.parse(json['measurementTime']),
      weatherDescription: json['weatherDescription'] ?? '',
      weatherCode: json['weatherCode'] ?? 0, // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'cloudCover': cloudCover,
      'measurementTime': measurementTime.toIso8601String(),
      'weatherDescription': weatherDescription,
      'weatherCode': weatherCode,
    };
  }
}
