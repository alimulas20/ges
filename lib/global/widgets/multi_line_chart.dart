import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_ges_360/global/extensions/context_extention.dart';

import '../constant/app_constants.dart';

class MultiLineChart extends StatelessWidget {
  final List<ChartSeries> seriesList;
  final String? bottomDescription;
  final bool showArea;
  final bool isCurved;

  const MultiLineChart({super.key, required this.seriesList, this.bottomDescription, this.showArea = false, this.isCurved = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 250, // Minimum yükseklik
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Maksimum yükseklik
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlanma
          children: [
            Expanded(
              // Grafik alanını genişlet
              child: Padding(padding: const EdgeInsets.only(top: AppConstants.paddingLarge), child: _buildChart()),
            ),
            if (bottomDescription != null) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Text(bottomDescription!, style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeSmall)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final series = seriesList[spot.barIndex];
                return LineTooltipItem(
                  '${series.label}: ${spot.y.toStringAsFixed(1)} ${series.unit ?? ''}',
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: AppConstants.fontSizeSmall),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // İlk serinin zaman etiketlerini kullanıyoruz
                if (seriesList.isNotEmpty && value.toInt() >= 0 && value.toInt() < seriesList.first.dataPoints.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Text(seriesList.first.dataPoints[value.toInt()].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey)),
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
                return Text(value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1), style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: seriesList.isNotEmpty ? (seriesList.first.dataPoints.length - 1).toDouble() : 0,
        minY: _calculateMinY(),
        maxY: _calculateMaxY(),
        lineBarsData:
            seriesList.map((series) {
              return LineChartBarData(
                spots:
                    series.dataPoints.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.value);
                    }).toList(),
                isCurved: isCurved,
                color: series.color,
                curveSmoothness: 0.05,
                barWidth: AppConstants.chartLineThickness,
                dotData: const FlDotData(show: false),
                belowBarData:
                    showArea
                        ? BarAreaData(show: true, gradient: LinearGradient(colors: [series.color.withAlpha(76), series.color.withAlpha(25)], begin: Alignment.topCenter, end: Alignment.bottomCenter))
                        : BarAreaData(show: false),
              );
            }).toList(),
      ),
    );
  }

  double _calculateMinY() {
    double min = 0;
    for (final series in seriesList) {
      for (final point in series.dataPoints) {
        if (point.value < min) min = point.value;
      }
    }
    return min < 0 ? min * 1.2 : 0;
  }

  double _calculateMaxY() {
    double max = 0;
    for (final series in seriesList) {
      for (final point in series.dataPoints) {
        if (point.value > max) max = point.value;
      }
    }
    return max * 1.2; // %20 boşluk bırak
  }
}

class ChartSeries {
  final List<ChartDataPoint> dataPoints;
  final Color color;
  final String label;
  final String? unit;

  ChartSeries({required this.dataPoints, required this.color, required this.label, this.unit});
}

class ChartDataPoint {
  final double value;
  final String timeLabel;

  ChartDataPoint({required this.value, required this.timeLabel});
}
