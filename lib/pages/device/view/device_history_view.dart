// views/device_history_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';
import '../viewmodel/device_history_view_model.dart';

class DeviceHistoryView extends StatefulWidget {
  final int deviceSetupId;

  const DeviceHistoryView({super.key, required this.deviceSetupId});

  @override
  State<DeviceHistoryView> createState() => _DeviceHistoryViewState();
}

class _DeviceHistoryViewState extends State<DeviceHistoryView> {
  late final DeviceHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceHistoryViewModel(DeviceSetupService(), widget.deviceSetupId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geçmiş Veriler', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _viewModel.setSelectedDate(DateTime.now());
              },
            ),
          ],
        ),
        body: Consumer<DeviceHistoryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.attributes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSuperLarge), child: Text(viewModel.errorMessage!, textAlign: TextAlign.center)),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    ElevatedButton(onPressed: () => _viewModel.setSelectedDate(DateTime.now()), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Inverter Data Section
                  _buildInverterDataSection(context, viewModel),

                  const SizedBox(height: AppConstants.paddingExtraLarge),
                  const Divider(),
                  const SizedBox(height: AppConstants.paddingExtraLarge),

                  // PV Comparison Section
                  _buildPvComparisonSection(context, viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInverterDataSection(BuildContext context, DeviceHistoryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ... tarih ve dropdown seçimleri aynı
        const SizedBox(height: AppConstants.paddingExtraLarge),

        // Inverter Graph - FL Chart ile
        if (viewModel.isLoadingInverterData)
          const Center(child: CircularProgressIndicator())
        else if (viewModel.inverterData != null)
          Container(
            height: 250,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(enabled: true),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(viewModel.inverterData['labels'][value.toInt()]);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(viewModel.inverterData['labels'].length, (i) => FlSpot(i.toDouble(), viewModel.inverterData['data'][i].toDouble())),
                    isCurved: false,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPvComparisonSection(BuildContext context, DeviceHistoryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ... ölçüm türü ve PV string seçimleri aynı
        const SizedBox(height: AppConstants.paddingExtraLarge),

        // PV Comparison Graph - FL Chart ile
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              if (viewModel.pvComparisonData != null)
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(enabled: true),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: viewModel.calculateInterval(viewModel.pvComparisonData!),
                            getTitlesWidget: (value, meta) {
                              // Optimized timestamp handling
                              final hour = (value / 3600000).floor() % 24;
                              return Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('$hour:00', style: const TextStyle(fontSize: 10)));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: viewModel.calculateValueInterval(viewModel.pvComparisonData!),
                            getTitlesWidget: (value, meta) {
                              return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      minX: viewModel.pvComparisonData!.dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble(),
                      maxX: viewModel.pvComparisonData!.dataPoints.last.timestamp.millisecondsSinceEpoch.toDouble(),
                      lineBarsData: _buildOptimizedPvComparisonLineBars(viewModel),
                    ),
                  ),
                ),
              if (viewModel.isLoadingPvComparison) Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> _buildOptimizedPvComparisonLineBars(DeviceHistoryViewModel viewModel) {
    if (viewModel.pvComparisonData == null) return [];

    final colors = [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple];
    final lineBars = <LineChartBarData>[];
    var colorIndex = 0;

    // Group data by PV string name
    final pvStringNames = viewModel.pvComparisonData!.dataPoints.expand((point) => point.values.keys).toSet().toList();

    for (final pvStringName in pvStringNames) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      final spots = <FlSpot>[];
      for (final point in viewModel.pvComparisonData!.dataPoints) {
        if (point.values.containsKey(pvStringName)) {
          spots.add(FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.values[pvStringName]!));
        }
      }

      lineBars.add(
        LineChartBarData(
          color: color,
          barWidth: 2,
          isCurved: true,
          dotData: FlDotData(show: false), // Disable dots to improve performance
          spots: spots,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return lineBars;
  }

  List<LineChartBarData> _buildPvComparisonLineBars(DeviceHistoryViewModel viewModel) {
    if (viewModel.pvComparisonData == null) return [];

    final colors = [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple];

    var colorIndex = 0;

    return viewModel.pvComparisonData!.dataPoints.expand((point) => point.values.entries).map((entry) => entry.key).toSet().map((pvStringName) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return LineChartBarData(
        color: color,
        barWidth: 2,
        isCurved: false,
        dotData: FlDotData(show: true),
        spots:
            viewModel.pvComparisonData!.dataPoints
                .where((point) => point.values.containsKey(pvStringName))
                .map((point) => FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.values[pvStringName]!.toDouble()))
                .toList(),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }
}
