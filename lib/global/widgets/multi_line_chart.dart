import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constant/app_constants.dart';
import '../extensions/context_extention.dart';
import 'chart_tooltip_widget.dart';

class MultiLineChart extends StatefulWidget {
  final List<ChartSeries> seriesList;
  final String? bottomDescription;
  final bool showArea;
  final bool isCurved;

  const MultiLineChart({super.key, required this.seriesList, this.bottomDescription, this.showArea = false, this.isCurved = true});

  @override
  State<MultiLineChart> createState() => _MultiLineChartState();
}

class _MultiLineChartState extends State<MultiLineChart> {
  int? _touchedIndex;
  Offset? _touchLocationGlobal;
  final GlobalKey _chartStackKey = GlobalKey();

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    key: _chartStackKey,
                    children: [
                      Padding(padding: const EdgeInsets.only(top: AppConstants.paddingLarge), child: _buildChart()),
                      // Custom tooltip - gerçek boyutları kullanarak konumlandır
                      if (_touchedIndex != null) _buildCustomTooltip(constraints),
                    ],
                  );
                },
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
                _touchLocationGlobal = touchResponse.touchLocation;
              });
            } else if (event is FlPanEndEvent) {
              // Pan bittiğinde tooltip'i kapat
              setState(() {
                _touchedIndex = null;
                _touchLocationGlobal = null;
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
                      return FlDotCirclePainter(radius: 6, color: series.color, strokeWidth: 2, strokeColor: Colors.white);
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

  Widget _buildCustomTooltip(BoxConstraints constraints) {
    if (_touchedIndex == null) return const SizedBox.shrink();

    final index = _touchedIndex!;

    if (index < 0) return const SizedBox.shrink();

    // Tüm serilerin bu noktadaki değerlerini topla
    final tooltipItems = <ChartTooltipItem>[];
    String? timeLabel;

    for (final series in widget.seriesList) {
      if (index < series.dataPoints.length) {
        final dataPoint = series.dataPoints[index];
        timeLabel ??= dataPoint.timeLabel;
        tooltipItems.add(ChartTooltipItem(label: series.label, value: dataPoint.value, unit: series.unit ?? '', color: series.color));
      }
    }

    if (tooltipItems.isEmpty || timeLabel == null) return const SizedBox.shrink();

    // İlk serinin değerini referans olarak kullan (pozisyon hesaplama için)
    final firstSeries = widget.seriesList.first;
    final firstDataPoint = firstSeries.dataPoints[index];
    final referenceValue = firstDataPoint.value;

    // Gerçek grafik boyutlarını kullan
    final chartHeight = constraints.maxHeight - AppConstants.paddingLarge;
    final chartWidth = constraints.maxWidth;

    // Y pozisyonunu hesapla (referans değere göre)
    final maxY = _calculateMaxY();
    final minY = _calculateMinY();
    final pointY = chartHeight - (((referenceValue - minY) / (maxY - minY)) * chartHeight);

    // Tooltip maksimum boyutları (chart_tooltip_widget.dart ile uyumlu)
    final maxTooltipWidth = MediaQuery.of(context).size.width * 0.6; // Ekran genişliğinin %60'ı
    const maxTooltipHeight = 150.0; // Maksimum yükseklik (daha küçük)
    final needsScroll = tooltipItems.length > 3; // 3'ten fazla item varsa scroll

    // Tooltip yüksekliği (yaklaşık) - scroll gerekiyorsa maksimum yüksekliği kullan
    final tooltipHeight = needsScroll ? maxTooltipHeight : (28.0 + (tooltipItems.length * 24.0) + 16.0).clamp(0.0, maxTooltipHeight); // 16 padding için

    final estimatedWidth = _estimateMultiTooltipWidth(
      context: context,
      timeLabel: timeLabel,
      items: tooltipItems,
      maxTooltipWidth: maxTooltipWidth,
    );

    // X pozisyonunu hesapla (yedek): plot alanı + sol eksen payı
    final maxX = widget.seriesList.isNotEmpty ? (widget.seriesList.first.dataPoints.length - 1).toDouble() : 0.0;
    final safeMaxX = maxX <= 0 ? 1.0 : maxX;
    final plotWidth = chartWidth - AppConstants.chartLeftAxisWidth;
    final pointX = AppConstants.chartLeftAxisWidth + (index / safeMaxX) * plotWidth;
    // Birincil anchor: gerçek dokunma pikseli (daha stabil)
    final stackBox = _chartStackKey.currentContext?.findRenderObject() as RenderBox?;
    final touchLocalX = (_touchLocationGlobal != null && stackBox != null && stackBox.hasSize) ? stackBox.globalToLocal(_touchLocationGlobal!).dx : null;
    final anchorX = touchLocalX ?? pointX;

    // Akıllı Y pozisyonlandırma
    // Önce üstte yer var mı kontrol et
    final spaceAbove = pointY;
    final spaceBelow = chartHeight - pointY;

    // Güvenli clamp değerleri hesapla
    final minYPos = 8.0;
    final maxYPos = (chartHeight - tooltipHeight - 8.0).clamp(minYPos, double.infinity);

    double yPosition;

    if (spaceAbove >= tooltipHeight + 20) {
      // Üstte yeterli yer var, üste koy
      yPosition = (pointY - tooltipHeight - 20).clamp(minYPos, maxYPos);
    } else if (spaceBelow >= tooltipHeight + 20) {
      // Altta yeterli yer var, alta koy
      yPosition = (pointY + 20).clamp(minYPos, maxYPos);
    } else {
      // Ne üstte ne altta yeterli yer yok, mevcut alanı kullan
      if (spaceAbove > spaceBelow) {
        // Üstte daha fazla yer var
        yPosition = (pointY - tooltipHeight).clamp(minYPos, maxYPos);
      } else {
        // Altta daha fazla yer var
        yPosition = (pointY + 20).clamp(minYPos, maxYPos);
      }
    }

    // X konumu: tek ve sürekli formül.
    // Noktanın sağında başlamayı dener, sığmıyorsa sağ sınıra clamp eder.
    // Böylece küçük tıklama farklarında ani taraf değişimi olmaz.
    const edgePadding = 8.0;
    const sideGap = 4.0;
    final minX = edgePadding;
    final maxXPos = (chartWidth - estimatedWidth - edgePadding).clamp(minX, double.infinity);
    final xPosition = (anchorX + sideGap).clamp(minX, maxXPos);

    return Positioned(
      left: xPosition,
      top: yPosition,
      child: ChartTooltipWidget(
        timeLabel: timeLabel,
        items: tooltipItems,
        onClose: () {
          setState(() {
            _touchedIndex = null;
            _touchLocationGlobal = null;
          });
        },
      ),
    );
  }

  double _estimateMultiTooltipWidth({
    required BuildContext context,
    required String timeLabel,
    required List<ChartTooltipItem> items,
    required double maxTooltipWidth,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final timeStyle = TextStyle(color: onSurface, fontSize: AppConstants.fontSizeSmall, fontWeight: FontWeight.bold);
    final labelStyle = TextStyle(color: onSurface, fontSize: AppConstants.fontSizeSmall, fontWeight: FontWeight.w500);
    final valueStyle = TextStyle(color: onSurface, fontSize: AppConstants.fontSizeSmall, fontWeight: FontWeight.w600);

    double textWidth(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return painter.width;
    }

    final timeRowWidth = 14.0 + 6.0 + textWidth(timeLabel, timeStyle);
    double maxDataRowWidth = 0;
    for (final item in items) {
      final label = '${item.label}: ';
      final value = '${item.value.toStringAsFixed(1)} ${item.unit}';
      final rowWidth = 12.0 + 6.0 + textWidth(label, labelStyle) + textWidth(value, valueStyle);
      if (rowWidth > maxDataRowWidth) maxDataRowWidth = rowWidth;
    }

    final contentWidth = (timeRowWidth > maxDataRowWidth ? timeRowWidth : maxDataRowWidth) + 24.0; // close alanı
    final containerWidth = contentWidth + 12.0 + 8.0; // dış padding
    final clamped = containerWidth.clamp(140.0, maxTooltipWidth);
    return clamped.toDouble();
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
