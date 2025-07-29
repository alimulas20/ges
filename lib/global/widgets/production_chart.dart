import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../global/constant/app_constants.dart';
import '../../pages/plant/models/plant_production_model.dart';

class ProductionChart extends StatelessWidget {
  final List<ProductionDataPointDTO> dataPoints;
  final String? bottomDescription;
  final Function getBottomTitle;
  const ProductionChart({super.key, required this.dataPoints, this.bottomDescription, required this.getBottomTitle});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('Görüntülenecek veri bulunamadı'));
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                lineTouchData: const LineTouchData(enabled: true),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return getBottomTitle(date);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppConstants.chartLeftAxisWidth,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble(),
                maxX: dataPoints.last.timestamp.millisecondsSinceEpoch.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints.map((point) => FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.totalProduction)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: AppConstants.chartLineThickness,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(bottomDescription ?? ""),
        ],
      ),
    );
  }
}
