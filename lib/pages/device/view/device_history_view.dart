// views/device_history_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../global/widgets/multi_select_dropdown.dart';
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

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                  ),
                );
              },
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
        // Responsive row for smaller screens
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(children: [_buildAttributeDropdown(viewModel), const SizedBox(height: AppConstants.paddingMedium), _buildDatePicker(viewModel)]);
            }
            return Row(children: [Expanded(child: _buildAttributeDropdown(viewModel)), const SizedBox(width: AppConstants.paddingMedium), Expanded(child: _buildDatePicker(viewModel))]);
          },
        ),
        const SizedBox(height: AppConstants.paddingExtraLarge),

        if (viewModel.isLoadingInverterData)
          const Center(child: CircularProgressIndicator())
        else if (viewModel.inverterComparisonData != null)
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
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10)));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: viewModel.inverterComparisonData!.dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble(),
                maxX: viewModel.inverterComparisonData!.dataPoints.last.timestamp.millisecondsSinceEpoch.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        viewModel.inverterComparisonData!.dataPoints
                            .map((point) => FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.values[viewModel.selectedAttribute!] ?? 0))
                            .toList(),
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttributeDropdown(DeviceHistoryViewModel viewModel) {
    return DropdownButtonFormField<String>(
      value: viewModel.selectedAttribute,
      items: viewModel.attributes.map((attr) => DropdownMenuItem(value: attr.key, child: Text(attr.name))).toList(),
      onChanged: viewModel.setSelectedAttribute,
      decoration: const InputDecoration(labelText: 'Inverter Özelliği', border: OutlineInputBorder()),
    );
  }

  Widget _buildDatePicker(DeviceHistoryViewModel viewModel) {
    return InkWell(
      onTap: () => _selectDate(context, viewModel),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Tarih', border: OutlineInputBorder()),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(DateFormat('dd/MM/yyyy').format(viewModel.selectedDate)), const Icon(Icons.calendar_today, size: 20)]),
      ),
    );
  }

  Widget _buildPvComparisonSection(BuildContext context, DeviceHistoryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Responsive row for smaller screens
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(children: [_buildMeasurementTypeDropdown(viewModel), const SizedBox(height: AppConstants.paddingMedium), _buildPvStringDropdown(viewModel)]);
            }
            return Row(children: [Expanded(child: _buildMeasurementTypeDropdown(viewModel)), const SizedBox(width: AppConstants.paddingMedium), Expanded(child: _buildPvStringDropdown(viewModel))]);
          },
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // Selected PV strings chips
        if (viewModel.selectedPvStringIds.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            children:
                viewModel.selectedPvStringIds.map((id) {
                  final pvString = viewModel.pvStrings.firstWhere((pv) => pv.id == id);
                  return Chip(
                    label: Text(pvString.name),
                    onDeleted: () {
                      viewModel.setSelectedPvStrings(viewModel.selectedPvStringIds.where((item) => item != id).toList());
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
        ],

        const SizedBox(height: AppConstants.paddingExtraLarge),

        // PV Comparison Graph
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              if (viewModel.pvComparisonData != null && viewModel.selectedPvStringIds.isNotEmpty)
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
                              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              return Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10)));
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
              if (viewModel.isLoadingPvComparison) const Center(child: CircularProgressIndicator()),
              if (viewModel.pvComparisonData == null && !viewModel.isLoadingPvComparison) const Center(child: Text('Lütfen PV String seçiniz')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementTypeDropdown(DeviceHistoryViewModel viewModel) {
    return DropdownButtonFormField<PVMeasurementType>(
      value: viewModel.selectedMeasurementType,
      items: PVMeasurementType.values.map((type) => DropdownMenuItem(value: type, child: Text(_getMeasurementTypeName(type)))).toList(),
      onChanged: (type) => viewModel.setSelectedMeasurementType(type!),
      decoration: const InputDecoration(labelText: 'Ölçüm Türü', border: OutlineInputBorder()),
    );
  }

  String _getMeasurementTypeName(PVMeasurementType type) {
    switch (type) {
      case PVMeasurementType.Power:
        return 'Güç (W)';
      case PVMeasurementType.Current:
        return 'Akım (A)';
      case PVMeasurementType.Voltage:
        return 'Voltaj (V)';
      default:
        return type.toString().split('.').last;
    }
  }

  Widget _buildPvStringDropdown(DeviceHistoryViewModel viewModel) {
    return MultiSelectDropdown(
      options: viewModel.pvStrings.map((pv) => DropdownMenuItem(value: pv.id, child: Text(pv.name))).toList(),
      selectedValues: viewModel.selectedPvStringIds,
      onChanged: (ids) => viewModel.setSelectedPvStrings(ids),
      hint: 'PV String Seçiniz',
    );
  }

  Future<void> _selectDate(BuildContext context, DeviceHistoryViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: viewModel.selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.setSelectedDate(picked);
    }
  }

  List<LineChartBarData> _buildOptimizedPvComparisonLineBars(DeviceHistoryViewModel viewModel) {
    if (viewModel.pvComparisonData == null) return [];

    final colors = [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple];
    final lineBars = <LineChartBarData>[];
    var colorIndex = 0;

    // Get names of selected PV strings
    final selectedPvStrings = viewModel.pvStrings.where((pv) => viewModel.selectedPvStringIds.contains(pv.id)).toList();

    for (final pvString in selectedPvStrings) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      final spots = <FlSpot>[];
      for (final point in viewModel.pvComparisonData!.dataPoints) {
        if (point.values.containsKey(pvString.name)) {
          spots.add(FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.values[pvString.name]!));
        }
      }

      lineBars.add(LineChartBarData(color: color, barWidth: 2, isCurved: true, dotData: FlDotData(show: false), spots: spots, belowBarData: BarAreaData(show: false)));
    }

    return lineBars;
  }
}
