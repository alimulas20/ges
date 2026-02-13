import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constant/app_constants.dart';
import '../extensions/context_extention.dart';
import 'chart_tooltip_widget.dart';

class MultiLineChart extends StatefulWidget {
  final List<ChartSeries> seriesList;
  final String? bottomDescription;
  final bool showArea;
  final bool isCurved;

  const MultiLineChart({
    super.key,
    required this.seriesList,
    this.bottomDescription,
    this.showArea = false,
    this.isCurved = true,
  });

  @override
  State<MultiLineChart> createState() => _MultiLineChartState();
}

class _MultiLineChartState extends State<MultiLineChart> {
  int? _touchedIndex;

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
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingLarge),
                    child: _buildChart(),
                  ),
                  // Custom tooltip
                  if (_touchedIndex != null) _buildCustomTooltip(),
                ],
              ),
            ),
            if (widget.bottomDescription != null) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Text(widget.bottomDescription!, style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeSmall)),
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
          handleBuiltInTouches: false,
          touchSpotThreshold: 20,
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            // Tap (basınca) ile tooltip göster
            if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
              final spot = touchResponse.lineBarSpots!.first;
              setState(() {
                _touchedIndex = spot.x.toInt();
              });
            } else if (event is FlPanEndEvent) {
              // Pan bittiğinde tooltip'i kapat
              setState(() {
                _touchedIndex = null;
              });
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => [], // Custom tooltip kullanacağız
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
                if (widget.seriesList.isNotEmpty && value.toInt() >= 0 && value.toInt() < widget.seriesList.first.dataPoints.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Text(widget.seriesList.first.dataPoints[value.toInt()].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey)),
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
        maxX: widget.seriesList.isNotEmpty ? (widget.seriesList.first.dataPoints.length - 1).toDouble() : 0,
        minY: _calculateMinY(),
        maxY: _calculateMaxY(),
        lineBarsData:
            widget.seriesList.map((series) {
              return LineChartBarData(
                spots:
                    series.dataPoints.asMap().entries.map((spotEntry) {
                      return FlSpot(spotEntry.key.toDouble(), spotEntry.value.value);
                    }).toList(),
                isCurved: widget.isCurved,
                color: series.color,
                curveSmoothness: 0.05,
                barWidth: AppConstants.chartLineThickness,
                dotData: FlDotData(
                  show: _touchedIndex != null,
                  getDotPainter: (spot, percent, barData, index) {
                    // Sadece tıklanan noktayı göster
                    if (_touchedIndex != null && spot.x.toInt() == _touchedIndex) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: series.color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    }
                    return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                  },
                ),
                belowBarData:
                    widget.showArea
                        ? BarAreaData(show: true, gradient: LinearGradient(colors: [series.color.withAlpha(76), series.color.withAlpha(25)], begin: Alignment.topCenter, end: Alignment.bottomCenter))
                        : BarAreaData(show: false),
              );
            }).toList(),
      ),
    );
  }

  double _calculateMinY() {
    double min = 0;
    for (final series in widget.seriesList) {
      for (final point in series.dataPoints) {
        if (point.value < min) min = point.value;
      }
    }
    return min < 0 ? min * 1.2 : 0;
  }

  double _calculateMaxY() {
    double max = 0;
    for (final series in widget.seriesList) {
      for (final point in series.dataPoints) {
        if (point.value > max) max = point.value;
      }
    }
    return max * 1.2; // %20 boşluk bırak
  }

  Widget _buildCustomTooltip() {
    if (_touchedIndex == null) return const SizedBox.shrink();

    final index = _touchedIndex!;
    
    if (index < 0) return const SizedBox.shrink();

    // Tüm serilerin bu noktadaki değerlerini topla
    final tooltipItems = <ChartTooltipItem>[];
    String? timeLabel;
    
    for (final series in widget.seriesList) {
      if (index < series.dataPoints.length) {
        final dataPoint = series.dataPoints[index];
        if (timeLabel == null) {
          timeLabel = dataPoint.timeLabel;
        }
        tooltipItems.add(ChartTooltipItem(
          label: series.label,
          value: dataPoint.value,
          unit: series.unit ?? '',
          color: series.color,
        ));
      }
    }

    if (tooltipItems.isEmpty || timeLabel == null) return const SizedBox.shrink();

    // İlk serinin değerini referans olarak kullan (pozisyon hesaplama için)
    final firstSeries = widget.seriesList.first;
    final firstDataPoint = firstSeries.dataPoints[index];
    final referenceValue = firstDataPoint.value;

    // Grafik yüksekliği ve genişliği
    const chartHeight = 250.0;
    final chartWidth = MediaQuery.of(context).size.width - (AppConstants.paddingExtraLarge * 2);

    // Y pozisyonunu hesapla (referans değere göre)
    final maxY = _calculateMaxY();
    final minY = _calculateMinY();
    final pointY = chartHeight - (((referenceValue - minY) / (maxY - minY)) * chartHeight);

    // Tooltip yüksekliği (yaklaşık) - her item için 24px + başlık için 28px
    final tooltipHeight = 28.0 + (tooltipItems.length * 24.0);

    // Eğer nokta grafiğin üst kısmındaysa (ilk %30), tooltip'i noktanın altına koy
    // Aksi halde tooltip'i noktanın üstüne koy
    final double yPosition;
    if (pointY < chartHeight * 0.3) {
      // Üst kısımda, tooltip'i noktanın altına koy
      yPosition = pointY + 20;
    } else {
      // Alt kısımda, tooltip'i noktanın üstüne koy
      yPosition = pointY - tooltipHeight;
    }

    // X pozisyonunu hesapla (grafik içindeki konum)
    final maxX = widget.seriesList.isNotEmpty ? (widget.seriesList.first.dataPoints.length - 1).toDouble() : 0.0;
    final pointX = (index / maxX) * chartWidth;

    // Tooltip'in yaklaşık genişliğini hesapla (içeriğe göre)
    // En uzun item'ı kullan
    double maxItemWidth = 0;
    for (final item in tooltipItems) {
      final itemWidth = (item.label.length + item.value.toStringAsFixed(1).length + item.unit.length) * 7.0 + 30.0;
      if (itemWidth > maxItemWidth) maxItemWidth = itemWidth;
    }
    final estimatedWidth = (timeLabel.length * 7.0) + maxItemWidth + 80.0;

    // X pozisyonunu ayarla - tooltip noktanın üzerinde ortalanmış olsun
    double xPosition = pointX - (estimatedWidth / 2);

    // Taşmayı önle
    xPosition = xPosition.clamp(8.0, chartWidth - estimatedWidth - 8.0);

    return Positioned(
      left: xPosition,
      top: yPosition.clamp(0.0, chartHeight - tooltipHeight),
      child: ChartTooltipWidget(
        timeLabel: timeLabel,
        items: tooltipItems,
        onClose: () {
          setState(() {
            _touchedIndex = null;
          });
        },
      ),
    );
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
