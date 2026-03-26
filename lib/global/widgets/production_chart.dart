import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../pages/plant/models/plant_production_model.dart';
import '../constant/app_constants.dart';

class ProductionChart extends StatefulWidget {
  final List<ProductionDataPointDTO> dataPoints;
  final List<ProductionDataPointDTO>? predictionDataPoints;
  final Color lineColor;
  final String? bottomDescription;
  final ProductionTimePeriod timePeriod;
  final String unit;

  const ProductionChart({super.key, required this.dataPoints, this.predictionDataPoints, this.lineColor = Colors.blueAccent, this.bottomDescription, required this.timePeriod, required this.unit});

  @override
  State<ProductionChart> createState() => _ProductionChartState();
}

class _ProductionChartState extends State<ProductionChart> {
  int? _touchedIndex;
  final GlobalKey _chartStackKey = GlobalKey();

  @override
  void didUpdateWidget(ProductionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tarih veya veri değiştiğinde detay tooltip'ini kapat (yeni veriye uyum için)
    if (oldWidget.dataPoints != widget.dataPoints ||
        oldWidget.predictionDataPoints != widget.predictionDataPoints) {
      if (_touchedIndex != null) {
        setState(() {
          _touchedIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return const Center(child: Text('Üretim verisi bulunamadı', style: TextStyle(color: Colors.grey, fontSize: AppConstants.fontSizeMedium)));
    }
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), boxShadow: AppConstants.elevatedShadow),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                key: _chartStackKey,
                children: [
                  SizedBox(
                    height: 250,
                    child: Padding(padding: const EdgeInsets.only(top: AppConstants.paddingLarge), child: widget.timePeriod == ProductionTimePeriod.daily ? _buildLineChart() : _buildBarChart()),
                  ),
                  // Custom tooltip - gerçek boyutları kullanarak konumlandır
                  if (_touchedIndex != null) _buildCustomTooltip(constraints),
                ],
              );
            },
          ),
          // Renkli açıklama (legend) - sadece günlük ve prediction varsa göster
          if (widget.timePeriod == ProductionTimePeriod.daily && widget.predictionDataPoints != null && widget.predictionDataPoints!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            _buildLegend(),
          ],
          if (widget.bottomDescription != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(widget.bottomDescription!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: AppConstants.fontSizeSmall)),
          ],
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    // Tüm verileri birleştir (maxY hesaplaması için)
    final allValues = <double>[];
    allValues.addAll(widget.dataPoints.map((e) => e.totalProduction));
    if (widget.predictionDataPoints != null && widget.predictionDataPoints!.isNotEmpty) {
      allValues.addAll(widget.predictionDataPoints!.map((e) => e.totalProduction));
    }

    final maxX =
        widget.predictionDataPoints != null && widget.predictionDataPoints!.isNotEmpty
            ? (widget.dataPoints.length + widget.predictionDataPoints!.length - 1).toDouble()
            : (widget.dataPoints.length - 1).toDouble();
    final maxY = allValues.isEmpty ? 100.0 : (allValues.reduce((a, b) => a > b ? a : b) * 1.2);
    const predictionColor = Colors.orange;

    // Prediction spots oluştur - gerçek verinin son noktasından sonrası
    List<FlSpot> predictionSpots = [];
    if (widget.predictionDataPoints != null && widget.predictionDataPoints!.isNotEmpty) {
      // Gerçek verinin son noktasıyla birleştir
      predictionSpots.add(FlSpot((widget.dataPoints.length - 1).toDouble(), widget.dataPoints.last.totalProduction));
      // Prediction noktaları
      for (var i = 0; i < widget.predictionDataPoints!.length; i++) {
        predictionSpots.add(FlSpot((widget.dataPoints.length + i).toDouble(), widget.predictionDataPoints![i].totalProduction));
      }
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchSpotThreshold: 20,
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            // Tap (basınca) ile tooltip göster; konumu tıklanan yerden al
            if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
              final spot = touchResponse.lineBarSpots!.first;
              setState(() {
                _touchedIndex = spot.x.toInt();
              });
            } else if (event is FlPanEndEvent) {
              setState(() {
                _touchedIndex = null;
              });
            }
          },
        ),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.dataPoints.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Text(widget.dataPoints[index].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey)),
                  );
                }
                // Prediction için de label göster
                if (widget.predictionDataPoints != null && index >= widget.dataPoints.length && index < widget.dataPoints.length + widget.predictionDataPoints!.length) {
                  final predictionIndex = index - widget.dataPoints.length;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Text(widget.predictionDataPoints![predictionIndex].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeExtraSmall, color: Colors.grey.withOpacity(0.6))),
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
                widget.dataPoints.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.totalProduction);
                }).toList(),
            isCurved: true,
            color: widget.lineColor,
            barWidth: AppConstants.chartLineThickness,
            dotData: FlDotData(
              show: _touchedIndex != null && _touchedIndex! < widget.dataPoints.length,
              getDotPainter: (spot, percent, barData, index) {
                // spot.x değeri grafikteki gerçek index'i temsil ediyor
                // Sadece tıklanan noktayı göster
                if (_touchedIndex != null && spot.x.toInt() == _touchedIndex) {
                  return FlDotCirclePainter(radius: 6, color: widget.lineColor, strokeWidth: 2, strokeColor: Colors.white);
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            showingIndicators: _touchedIndex != null && _touchedIndex! >= 0 && _touchedIndex! < widget.dataPoints.length ? [_touchedIndex!] : [],
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(colors: [widget.lineColor.withAlpha(76), widget.lineColor.withAlpha(25)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
          // Prediction çizgisi - gerçek verinin son noktasından sonrası
          if (predictionSpots.isNotEmpty)
            LineChartBarData(
              spots: predictionSpots,
              isCurved: true,
              color: predictionColor,
              barWidth: AppConstants.chartLineThickness,
              dotData: FlDotData(
                show: _touchedIndex != null && _touchedIndex! >= widget.dataPoints.length,
                getDotPainter: (spot, percent, barData, index) {
                  // spot.x değeri grafikteki gerçek index'i temsil ediyor
                  // Prediction spots'ların ilk elemanı (index 0) gerçek verinin son noktası, bunu gösterme
                  if (index == 0) {
                    return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                  }
                  // Sadece tıklanan noktayı göster
                  if (_touchedIndex != null && spot.x.toInt() == _touchedIndex) {
                    return FlDotCirclePainter(radius: 6, color: predictionColor, strokeWidth: 2, strokeColor: Colors.white);
                  }
                  return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                },
              ),
              dashArray: [5, 5], // Kesikli çizgi için
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxY = _calculateMaxY(widget.dataPoints);
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // Custom tooltip için index'i kaydet
              if (groupIndex >= 0 && groupIndex < widget.dataPoints.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _touchedIndex = group.x.toInt();
                    });
                  }
                });
              }
              // Built-in tooltip'i gizle (custom tooltip kullanacağız)
              return BarTooltipItem('', const TextStyle(fontSize: 0));
            },
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 0,
          ),
          touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
            // Dokunma bittiğinde tooltip'i kapat
            if (event is FlPanEndEvent) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _touchedIndex = null;
                  });
                }
              });
            }
          },
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
                if (index >= 0 && index < widget.dataPoints.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                    child: Transform.rotate(angle: 45, child: Text(widget.dataPoints[index].timeLabel, style: TextStyle(fontSize: AppConstants.fontSizeTiny, color: Colors.grey))),
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
            widget.dataPoints.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.totalProduction,
                    color: widget.lineColor,
                    width: 8,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    // Tıklanan bar'ı vurgula
                    backDrawRodData: _touchedIndex == entry.key ? BackgroundBarChartRodData(show: true, color: widget.lineColor.withOpacity(0.3)) : null,
                  ),
                ],
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

  Widget _buildCustomTooltip(BoxConstraints constraints) {
    if (_touchedIndex == null) return const SizedBox.shrink();

    final index = _touchedIndex!;

    // Bar chart için prediction kontrolü yok
    final isPrediction = widget.timePeriod == ProductionTimePeriod.daily && index >= widget.dataPoints.length;

    // Zaman etiketi ve değer bilgisini al
    String timeLabel = '';
    double value = 0;

    if (widget.timePeriod == ProductionTimePeriod.daily) {
      // Günlük grafik için prediction kontrolü
      if (isPrediction && widget.predictionDataPoints != null && index >= widget.dataPoints.length && index < widget.dataPoints.length + widget.predictionDataPoints!.length) {
        final predictionIndex = index - widget.dataPoints.length;
        timeLabel = widget.predictionDataPoints![predictionIndex].timeLabel;
        value = widget.predictionDataPoints![predictionIndex].totalProduction;
      } else if (index >= 0 && index < widget.dataPoints.length) {
        timeLabel = widget.dataPoints[index].timeLabel;
        value = widget.dataPoints[index].totalProduction;
      } else {
        return const SizedBox.shrink();
      }
    } else {
      // Aylık, yıllık, yaşam süresi için
      if (index >= 0 && index < widget.dataPoints.length) {
        timeLabel = widget.dataPoints[index].timeLabel;
        value = widget.dataPoints[index].totalProduction;
      } else {
        return const SizedBox.shrink();
      }
    }

    // Gerçek grafik boyutlarını kullan (fl_chart bottom titles reservedSize: 30)
    final chartHeight = 250.0 - 30.0;
    final chartWidth = constraints.maxWidth;

    // Y pozisyonunu hesapla (değere göre)
    final allValues = <double>[];
    allValues.addAll(widget.dataPoints.map((e) => e.totalProduction));
    if (widget.timePeriod == ProductionTimePeriod.daily && widget.predictionDataPoints != null && widget.predictionDataPoints!.isNotEmpty) {
      allValues.addAll(widget.predictionDataPoints!.map((e) => e.totalProduction));
    }
    final maxY = allValues.isEmpty ? 100.0 : (allValues.reduce((a, b) => a > b ? a : b) * 1.2);

    // Noktanın Y pozisyonunu hesapla
    final pointY = chartHeight - ((value / maxY) * chartHeight);

    // Tooltip yüksekliği (yaklaşık) - zaman + değer + padding
    const tooltipHeight = 60.0 + 16.0; // 16 padding için

    final tooltipValueText = '${value.toStringAsFixed(1)} ${widget.unit}${isPrediction ? " (Tahmin)" : ""}';
    final tooltipWidth = _calculateTooltipWidth(
      context: context,
      timeLabel: timeLabel,
      valueText: tooltipValueText,
    );

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

    // X pozisyonunu hesapla: fl_chart sol eksen için chartLeftAxisWidth ayırıyor,
    // çizim alanı [chartLeftAxisWidth, chartWidth] aralığında. Nokta konumu bu alana göre olmalı.
    final maxX =
        widget.predictionDataPoints != null && widget.predictionDataPoints!.isNotEmpty
            ? (widget.dataPoints.length + widget.predictionDataPoints!.length - 1).toDouble()
            : (widget.dataPoints.length - 1).toDouble();
    final plotWidth = chartWidth - AppConstants.chartLeftAxisWidth;
    final pointX = AppConstants.chartLeftAxisWidth + (index / maxX) * plotWidth;

    // X konumu: 4 koşul (sol/sağ + sığar/sığmaz) ve tıklanan noktaya 3px offset
    const edgePadding = 8.0;
    const sideGap = 6.0;
    final minX = edgePadding;
    final maxXPos = (chartWidth - tooltipWidth - edgePadding).clamp(minX, double.infinity);

    // Tercih: mümkünse noktanın sağında göster; sağda yer yoksa solunda göster.
    // İki taraf da sıkışıksa ortala ve clamp et.
    final rightCandidate = pointX + sideGap;
    final leftCandidate = pointX - tooltipWidth - sideGap;
    final canShowRight = rightCandidate <= maxXPos;
    final canShowLeft = leftCandidate >= minX;

    double xPosition;
    if (canShowRight) {
      xPosition = rightCandidate;
    } else if (canShowLeft) {
      xPosition = leftCandidate;
    } else {
      xPosition = (pointX - (tooltipWidth / 2)).clamp(minX, maxXPos);
    }

    // Grafik Padding(top: paddingLarge) ile sarılı; nokta gerçek Y'si Stack'ta paddingLarge + pointY
    final topOffset = AppConstants.paddingLarge;
    final yPositionInStack = yPosition + topOffset;

    return Positioned(
      left: xPosition,
      top: yPositionInStack,
      child: _buildTooltipContent(timeLabel, value, isPrediction),
    );
  }

  Widget _buildTooltipContent(String timeLabel, double value, bool isPrediction) {
    return Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(timeLabel, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isPrediction ? Icons.trending_up : Icons.show_chart, size: 14, color: isPrediction ? Colors.orange : Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${value.toStringAsFixed(1)} ${widget.unit}${isPrediction ? " (Tahmin)" : ""}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: AppConstants.fontSizeSmall, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _touchedIndex = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.close, color: Theme.of(context).colorScheme.error, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildLegend() {
    const predictionColor = Colors.orange;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildLegendItem('Gerçek Veri', widget.lineColor), const SizedBox(width: AppConstants.paddingLarge), _buildLegendItem('Tahmin Edilen', predictionColor)],
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

  double _calculateTooltipWidth({
    required BuildContext context,
    required String timeLabel,
    required String valueText,
  }) {
    final baseStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: AppConstants.fontSizeSmall,
      fontWeight: FontWeight.w600,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    double textWidth(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      return painter.width;
    }

    // Row genişlikleri: icon(14) + gap(6) + text
    final row1 = 14.0 + 6.0 + textWidth(timeLabel, boldStyle);
    final row2 = 14.0 + 6.0 + textWidth(valueText, baseStyle);

    // İç yapı:
    // Stack içinde Column sağdan 24 padding alıyor (close butonu için)
    // Container dış padding: left 12, right 8
    final contentWidth = (row1 > row2 ? row1 : row2) + 24.0;
    final containerWidth = contentWidth + 12.0 + 8.0;

    // Güvenlik için minimum
    return containerWidth < 140.0 ? 140.0 : containerWidth;
  }
}
