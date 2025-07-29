import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../pages/plant/models/plant_production_model.dart';
import '../constant/app_constants.dart';

class ProductionChart extends StatelessWidget {
  final List<ProductionDataPointDTO> dataPoints;
  final String? bottomDescription;
  final Function getBottomTitle;
  final Color lineColor;

  const ProductionChart({super.key, required this.dataPoints, this.bottomDescription, required this.getBottomTitle, this.lineColor = Colors.blueAccent});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return Center(child: Text('Üretim verisi bulunamadı', style: TextStyle(color: Colors.grey, fontSize: AppConstants.fontSizeMedium)));
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: AppConstants.elevationLarge, offset: const Offset(0, AppConstants.elevationSmall))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppConstants.imageLargeSize + AppConstants.paddingSuperLarge,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                        return LineTooltipItem(
                          '${getBottomTitle(date)}\n${spot.y.toStringAsFixed(AppConstants.decimalPlaces)} kWh',
                          TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeSmall),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.grey.withAlpha(51), // 20% opacity
                        strokeWidth: AppConstants.chartLineThickness,
                      ),
                  getDrawingVerticalLine:
                      (value) => FlLine(
                        color: Colors.grey.withAlpha(51), // 20% opacity
                        strokeWidth: AppConstants.chartLineThickness,
                      ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppConstants.paddingSuperLarge,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
                          child: Text(getBottomTitle(date), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeExtraSmall)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppConstants.chartLeftAxisWidth,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(value < 1000 ? 0 : AppConstants.decimalPlaces),
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeExtraSmall),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withAlpha(76), // 30% opacity
                    width: AppConstants.chartLineThickness,
                  ),
                ),
                minX: dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble(),
                maxX: dataPoints.last.timestamp.millisecondsSinceEpoch.toDouble(),
                minY: 0,
                maxY: _calculateMaxY(dataPoints),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints.map((point) => FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.totalProduction)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: AppConstants.paddingSmall.toDouble(),
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withAlpha(76), // 30% opacity
                          lineColor.withAlpha(25), // 10% opacity
                        ],
                      ),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        lineColor,
                        lineColor.withAlpha(178), // 70% opacity
                      ],
                    ),
                  ),
                ],
              ),
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

  double _calculateMaxY(List<ProductionDataPointDTO> dataPoints) {
    final maxProduction = dataPoints.map((e) => e.totalProduction).reduce((a, b) => a > b ? a : b);
    return maxProduction * 1.2; // %20 boşluk bırak
  }
}
