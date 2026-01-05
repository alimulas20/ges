import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../pages/plant/models/plant_production_model.dart';
import '../constant/app_constants.dart';

class ProductionChart extends StatelessWidget {
  final List<ProductionDataPointDTO> dataPoints;
  final List<ProductionDataPointDTO>? predictionDataPoints;
  final Color lineColor;
  final String? bottomDescription;
  final ProductionTimePeriod timePeriod;
  final String unit;

  const ProductionChart({super.key, required this.dataPoints, this.predictionDataPoints, this.lineColor = Colors.blueAccent, this.bottomDescription, required this.timePeriod, required this.unit});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('Üretim verisi bulunamadı', style: TextStyle(color: Colors.grey, fontSize: AppConstants.fontSizeMedium)));
    }
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), boxShadow: AppConstants.elevatedShadow),
      child: Column(
        children: [
          SizedBox(height: 250, child: Padding(padding: const EdgeInsets.only(top: AppConstants.paddingLarge), child: timePeriod == ProductionTimePeriod.daily ? _buildLineChart() : _buildBarChart())),
          // Renkli açıklama (legend) - sadece günlük ve prediction varsa göster
          if (timePeriod == ProductionTimePeriod.daily && predictionDataPoints != null && predictionDataPoints!.isNotEmpty) ...[const SizedBox(height: AppConstants.paddingMedium), _buildLegend()],
          if (bottomDescription != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(bottomDescription!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeSmall)),
          ],
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    // Tüm verileri birleştir (maxY hesaplaması için)
    final allValues = <double>[];
    allValues.addAll(dataPoints.map((e) => e.totalProduction));
    if (predictionDataPoints != null && predictionDataPoints!.isNotEmpty) {
      allValues.addAll(predictionDataPoints!.map((e) => e.totalProduction));
    }

    final maxX = predictionDataPoints != null && predictionDataPoints!.isNotEmpty ? (dataPoints.length + predictionDataPoints!.length - 1).toDouble() : (dataPoints.length - 1).toDouble();
    final maxY = allValues.isEmpty ? 100.0 : (allValues.reduce((a, b) => a > b ? a : b) * 1.2);
    const predictionColor = Colors.orange;
    final predictionStartX = dataPoints.length.toDouble();

    // Prediction spots oluştur - gerçek verinin son noktasından sonrası
    List<FlSpot> predictionSpots = [];
    if (predictionDataPoints != null && predictionDataPoints!.isNotEmpty) {
      // Gerçek verinin son noktasıyla birleştir
      predictionSpots.add(FlSpot((dataPoints.length - 1).toDouble(), dataPoints.last.totalProduction));
      // Prediction noktaları
      for (var i = 0; i < predictionDataPoints!.length; i++) {
        predictionSpots.add(FlSpot((dataPoints.length + i).toDouble(), predictionDataPoints![i].totalProduction));
      }
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isPrediction = spot.x >= predictionStartX;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} $unit${isPrediction ? " (Tahmin)" : ""}',
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: AppConstants.fontSizeSmall),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dataPoints.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Text(dataPoints[index].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey)),
                  );
                }
                // Prediction için de label göster
                if (predictionDataPoints != null && index >= dataPoints.length && index < dataPoints.length + predictionDataPoints!.length) {
                  final predictionIndex = index - dataPoints.length;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Text(predictionDataPoints![predictionIndex].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey.withOpacity(0.6))),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: AppConstants.chartLeftAxisWidth,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Gerçek veri çizgisi
          LineChartBarData(
            spots:
                dataPoints.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.totalProduction);
                }).toList(),
            isCurved: true,
            color: lineColor,
            barWidth: AppConstants.chartLineThickness,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [lineColor.withAlpha(76), lineColor.withAlpha(25)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          // Prediction çizgisi - gerçek verinin son noktasından sonrası
          if (predictionSpots.isNotEmpty)
            LineChartBarData(
              spots: predictionSpots,
              isCurved: true,
              color: predictionColor,
              barWidth: AppConstants.chartLineThickness,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5], // Kesikli çizgi için
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxY = _calculateMaxY(dataPoints);
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem('${rod.toY.toStringAsFixed(1)} $unit', const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: AppConstants.fontSizeSmall));
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dataPoints.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Transform.rotate(angle: 45, child: Text(dataPoints[index].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeTiny, color: Colors.grey))),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: AppConstants.chartLeftAxisWidthLarge,
              interval: maxY / 10, // 5 eşit aralık
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(value.toInt().toString(), style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey), textAlign: TextAlign.right),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY,
        barGroups:
            dataPoints.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [BarChartRodData(toY: entry.value.totalProduction, color: lineColor, width: 8, borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall))],
                //showingTooltipIndicators: [0],
              );
            }).toList(),
      ),
    );
  }

  double _calculateMaxY(List<ProductionDataPointDTO> dataPoints) {
    if (dataPoints.isEmpty) return 100;
    final max = dataPoints.map((e) => e.totalProduction).reduce((a, b) => a > b ? a : b);
    return max * 1.2; // %20 boşluk bırak
  }

  Widget _buildLegend() {
    const predictionColor = Colors.orange;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildLegendItem('Gerçek Veri', lineColor), const SizedBox(width: AppConstants.paddingLarge), _buildLegendItem('Tahmin Edilen', predictionColor)],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: AppConstants.paddingSmall),
        Text(label, style: TextStyle(fontSize: AppConstants.fontSizeSmall, color: Colors.grey[700])),
      ],
    );
  }
}
