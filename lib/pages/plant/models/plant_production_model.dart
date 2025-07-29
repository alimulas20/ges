class PlantProductionDTO {
  final int plantId;
  final String plantName;
  final List<ProductionDataPointDTO> dataPoints;
  final String unit;
  final ProductionTimePeriod timePeriod;
  final DateTime selectedDate;

  PlantProductionDTO({required this.plantId, required this.plantName, required this.dataPoints, this.unit = "kWh", required this.timePeriod, required this.selectedDate});

  factory PlantProductionDTO.fromJson(Map<String, dynamic> json) {
    return PlantProductionDTO(
      plantId: json['plantId'],
      plantName: json['plantName'],
      dataPoints: (json['dataPoints'] as List).map((e) => ProductionDataPointDTO.fromJson(e)).toList(),
      unit: json['unit'] ?? "kWh",
      timePeriod: ProductionTimePeriod.values[json['timePeriod']],
      selectedDate: DateTime.parse(json['selectedDate']),
    );
  }
}

class ProductionDataPointDTO {
  final DateTime timestamp;
  final double totalProduction;
  final String timeLabel;

  ProductionDataPointDTO({required this.timestamp, required this.totalProduction, required this.timeLabel});

  factory ProductionDataPointDTO.fromJson(Map<String, dynamic> json) {
    return ProductionDataPointDTO(timestamp: DateTime.parse(json['timestamp']), totalProduction: json['totalProduction'].toDouble(), timeLabel: json['timeLabel']);
  }
}

enum ProductionTimePeriod { daily, monthly, yearly, lifetime }

extension ProductionTimePeriodExtension on ProductionTimePeriod {
  String get displayName {
    switch (this) {
      case ProductionTimePeriod.daily:
        return "Günlük";
      case ProductionTimePeriod.monthly:
        return "Aylık";
      case ProductionTimePeriod.yearly:
        return "Yıllık";
      case ProductionTimePeriod.lifetime:
        return "Yaşam Süresi";
    }
  }
}
