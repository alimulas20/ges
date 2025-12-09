// plant_dto.dart
class PlantDto {
  final int id;
  final String name;
  final String plantType;
  final double totalStringCapacityKWp;
  final String address;
  final String countryOrRegion;
  final String? serviceProvider;
  final String? contactPerson;
  final String? email;
  final DateTime gridConnectionDate;
  final DateTime? safeRunningStartDate;
  final DateTime? updatedDate;
  final String? currency;
  final double latitude;
  final double longitude;
  final double altitude;
  final String? plantPicture;

  PlantDto({
    required this.id,
    required this.name,
    required this.plantType,
    required this.totalStringCapacityKWp,
    required this.address,
    required this.countryOrRegion,
    this.serviceProvider,
    this.contactPerson,
    this.email,
    required this.gridConnectionDate,
    this.safeRunningStartDate,
    this.updatedDate,
    this.currency,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    this.plantPicture,
  });

  factory PlantDto.fromJson(Map<String, dynamic> json) {
    return PlantDto(
      id: json['id'],
      name: json['name'],
      plantType: json['plantType'],
      totalStringCapacityKWp: json['totalStringCapacityKWp']?.toDouble() ?? 0.0,
      address: json['address'],
      countryOrRegion: json['countryOrRegion'],
      serviceProvider: json['serviceProvider'],
      contactPerson: json['contactPerson'],
      email: json['email'],
      gridConnectionDate: DateTime.parse(json['gridConnectionDate']),
      safeRunningStartDate: json['safeRunningStartDate'] != null ? DateTime.parse(json['safeRunningStartDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']) : null,
      currency: json['currency'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      altitude: json['altitude']?.toDouble() ?? 0.0,
      plantPicture: json['plantPicture'] ?? json['plantPictureUrl'], // Support both for backward compatibility
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
      if (serviceProvider != null) 'serviceProvider': serviceProvider,
      if (contactPerson != null) 'contactPerson': contactPerson,
      if (email != null) 'email': email,
      'gridConnectionDate': gridConnectionDate.toIso8601String(),
      if (safeRunningStartDate != null) 'safeRunningStartDate': safeRunningStartDate!.toIso8601String(),
      if (updatedDate != null) 'updatedDate': updatedDate!.toIso8601String(),
      if (currency != null) 'currency': currency,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      if (plantPicture != null) 'plantPicture': plantPicture,
    };
  }

  PlantDto copyWith({
    int? id,
    String? name,
    String? plantType,
    double? totalStringCapacityKWp,
    String? address,
    String? countryOrRegion,
    String? serviceProvider,
    String? contactPerson,
    String? email,
    DateTime? gridConnectionDate,
    DateTime? safeRunningStartDate,
    DateTime? updatedDate,
    String? currency,
    double? latitude,
    double? longitude,
    double? altitude,
    String? plantPicture,
  }) {
    return PlantDto(
      id: id ?? this.id,
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      totalStringCapacityKWp: totalStringCapacityKWp ?? this.totalStringCapacityKWp,
      address: address ?? this.address,
      countryOrRegion: countryOrRegion ?? this.countryOrRegion,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      gridConnectionDate: gridConnectionDate ?? this.gridConnectionDate,
      safeRunningStartDate: safeRunningStartDate ?? this.safeRunningStartDate,
      updatedDate: updatedDate ?? this.updatedDate,
      currency: currency ?? this.currency,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      plantPicture: plantPicture ?? this.plantPicture,
    );
  }
}

class PlantUpdateDto {
  final int id;
  final String name;
  final String plantType;
  final double totalStringCapacityKWp;
  final String address;
  final String countryOrRegion;
  final String? serviceProvider;
  final String? contactPerson;
  final String? email;
  final DateTime gridConnectionDate;
  final DateTime? safeRunningStartDate;
  final String? currency;
  final double latitude;
  final double longitude;
  final double altitude;

  PlantUpdateDto({
    required this.id,
    required this.name,
    required this.plantType,
    required this.totalStringCapacityKWp,
    required this.address,
    required this.countryOrRegion,
    this.serviceProvider,
    this.contactPerson,
    this.email,
    required this.gridConnectionDate,
    this.safeRunningStartDate,
    this.currency,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantType': plantType,
      'totalStringCapacityKWp': totalStringCapacityKWp,
      'address': address,
      'countryOrRegion': countryOrRegion,
      if (serviceProvider != null) 'serviceProvider': serviceProvider,
      if (contactPerson != null) 'contactPerson': contactPerson,
      if (email != null) 'email': email,
      'gridConnectionDate': gridConnectionDate.toIso8601String(),
      if (safeRunningStartDate != null) 'safeRunningStartDate': safeRunningStartDate!.toIso8601String(),
      if (currency != null) 'currency': currency,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
    };
  }

  factory PlantUpdateDto.fromPlant(PlantDto plant) {
    return PlantUpdateDto(
      id: plant.id,
      name: plant.name,
      plantType: plant.plantType,
      totalStringCapacityKWp: plant.totalStringCapacityKWp,
      address: plant.address,
      countryOrRegion: plant.countryOrRegion,
      serviceProvider: plant.serviceProvider,
      contactPerson: plant.contactPerson,
      email: plant.email,
      gridConnectionDate: plant.gridConnectionDate,
      safeRunningStartDate: plant.safeRunningStartDate,
      currency: plant.currency,
      latitude: plant.latitude,
      longitude: plant.longitude,
      altitude: plant.altitude,
    );
  }
}
