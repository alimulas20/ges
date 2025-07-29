import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../pages/plant/models/plant_production_model.dart';
import '../constant/app_constants.dart';

class ProductionChart extends StatelessWidget {
  final List<ProductionDataPointDTO> dataPoints;
  final Color lineColor;
  final String? bottomDescription;
  final ProductionTimePeriod timePeriod;

  const ProductionChart({super.key, required this.dataPoints, this.lineColor = Colors.blueAccent, this.bottomDescription, required this.timePeriod});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('Üretim verisi bulunamadı', style: TextStyle(color: Colors.grey, fontSize: AppConstants.fontSizeMedium)));
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.only(top: AppConstants.paddingLarge),
              child: timePeriod == ProductionTimePeriod.daily || timePeriod == ProductionTimePeriod.monthly ? _buildLineChart() : _buildBarChart(),
            ),
          ),
          if (bottomDescription != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(bottomDescription!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeSmall)),
          ],
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem('${spot.y.toStringAsFixed(1)} kWh', const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: AppConstants.fontSizeSmall));
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: false),
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
        maxX: (dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxY(dataPoints),
        lineBarsData: [
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
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem('${rod.toY.toStringAsFixed(1)} kWh', const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: AppConstants.fontSizeSmall));
            },
          ),
        ),
        gridData: FlGridData(show: false),
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
        minY: 0,
        maxY: _calculateMaxY(dataPoints),
        barGroups:
            dataPoints.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [BarChartRodData(toY: entry.value.totalProduction, color: lineColor, width: 16, borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall))],
                showingTooltipIndicators: [0],
              );
            }).toList(),
      ),
    );
  }

  double _calculateMaxY(List<ProductionDataPointDTO> dataPoints) {
    final max = dataPoints.map((e) => e.totalProduction).reduce((a, b) => a > b ? a : b);
    return max * 1.2; // %20 boşluk bırak
  }
}
