// views/device_history_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../global/constant/app_constants.dart';
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
          title: const Text('Geçmiş Veriler'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.setSelectedDate(DateTime.now()))],
          toolbarHeight: AppConstants.appBarHeight,
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
                    Text(viewModel.errorMessage!),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    ElevatedButton(onPressed: () => _viewModel.setSelectedDate(DateTime.now()), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Inverter Data Section with Multi-Select
                  _buildInverterSection(viewModel),
                  const SizedBox(height: AppConstants.paddingUltraLarge),
                  const Divider(),
                  const SizedBox(height: AppConstants.paddingUltraLarge),
                  // PV String Data Section
                  _buildPvStringSection(viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInverterSection(DeviceHistoryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Multi-select for Inverter Attributes
        MultiSelectDropdown<String>(
          options: viewModel.attributes.map((attr) => DropdownMenuItem(value: attr.key, child: Text(attr.name))).toList(),
          selectedValues: viewModel.selectedAttributeKeys,
          onChanged: (keys) => viewModel.setSelectedAttributeKeys(keys),
          hint: 'Inverter Özellikleri Seçiniz',
        ),
        const SizedBox(height: AppConstants.paddingExtraLarge),

        // Date Picker
        _buildDatePicker(viewModel),
        const SizedBox(height: AppConstants.paddingExtraLarge),

        // Selected Attributes Chips
        if (viewModel.selectedAttributeKeys.isNotEmpty) ...[
          Wrap(
            spacing: AppConstants.paddingSmall,
            children:
                viewModel.selectedAttributeKeys.map((key) {
                  final attr = viewModel.attributes.firstWhere((a) => a.key == key);
                  return Chip(label: Text(attr.name), onDeleted: () => viewModel.setSelectedAttributeKeys(viewModel.selectedAttributeKeys.where((k) => k != key).toList()));
                }).toList(),
          ),
          const SizedBox(height: AppConstants.paddingExtraLarge),
        ],

        // Inverter Chart
        SizedBox(height: 250, child: _buildInverterChart(viewModel)),
      ],
    );
  }

  Widget _buildInverterChart(DeviceHistoryViewModel viewModel) {
    if (viewModel.isLoadingInverterData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.inverterComparisonData == null || viewModel.selectedAttributeKeys.isEmpty) {
      return const Center(child: Text('Lütfen özellik seçiniz'));
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
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
                  return Text(DateFormat('HH:mm').format(date), style: const TextStyle(fontSize: AppConstants.fontSizeExtraSmall));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: AppConstants.chartLeftAxisWidth,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: AppConstants.fontSizeExtraSmall));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: viewModel.inverterComparisonData!.dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble(),
          maxX: viewModel.inverterComparisonData!.dataPoints.last.timestamp.millisecondsSinceEpoch.toDouble(),
          lineBarsData: _buildInverterLines(viewModel),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildInverterLines(DeviceHistoryViewModel viewModel) {
    final colors = [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple];
    final lineBars = <LineChartBarData>[];

    for (int i = 0; i < viewModel.selectedAttributeKeys.length; i++) {
      final key = viewModel.selectedAttributeKeys[i];
      final color = colors[i % colors.length];

      final spots = viewModel.inverterComparisonData!.dataPoints.map((point) => FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.values[key] ?? 0)).toList();

      lineBars.add(
        LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: AppConstants.chartLineThickness, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false)),
      );
    }

    return lineBars;
  }

  Widget _buildPvStringSection(DeviceHistoryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // First row - Measurement type and Date
        Row(children: [Expanded(child: _buildMeasurementTypeDropdown(viewModel)), const SizedBox(width: AppConstants.paddingExtraLarge), Expanded(child: _buildDatePicker(viewModel))]),
        const SizedBox(height: AppConstants.paddingExtraLarge),

        // PV String multi-select
        MultiSelectDropdown<int>(
          options: viewModel.pvStrings.map((pv) => DropdownMenuItem(value: pv.id, child: Text(pv.name))).toList(),
          selectedValues: viewModel.selectedPvStringIds,
          onChanged: (ids) => viewModel.setSelectedPvStrings(ids),
          hint: 'PV String Seçiniz',
        ),
        const SizedBox(height: AppConstants.paddingExtraLarge),

        // Selected PV strings chips
        if (viewModel.selectedPvStringIds.isNotEmpty) ...[
          Wrap(
            spacing: AppConstants.paddingSmall,
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
          const SizedBox(height: AppConstants.paddingExtraLarge),
        ],

        // PV Comparison Graph
        SizedBox(height: 250, child: _buildPvComparisonChart(viewModel)),
      ],
    );
  }

  Widget _buildPvComparisonChart(DeviceHistoryViewModel viewModel) {
    if (viewModel.isLoadingPvComparison) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.pvComparisonData == null || viewModel.selectedPvStringIds.isEmpty) {
      return const Center(child: Text('Lütfen PV String seçiniz'));
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
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
                  return Text(DateFormat('HH:mm').format(date), style: const TextStyle(fontSize: AppConstants.fontSizeExtraSmall));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: AppConstants.chartLeftAxisWidth,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: AppConstants.fontSizeExtraSmall));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: viewModel.pvComparisonData!.dataPoints.first.timestamp.millisecondsSinceEpoch.toDouble(),
          maxX: viewModel.pvComparisonData!.dataPoints.last.timestamp.millisecondsSinceEpoch.toDouble(),
          lineBarsData: _buildPvComparisonLines(viewModel),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildPvComparisonLines(DeviceHistoryViewModel viewModel) {
    final colors = [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple];
    final lineBars = <LineChartBarData>[];

    for (int i = 0; i < viewModel.selectedPvStringIds.length; i++) {
      final pvStringId = viewModel.selectedPvStringIds[i];
      final pvString = viewModel.pvStrings.firstWhere((pv) => pv.id == pvStringId);
      final color = colors[i % colors.length];

      final spots =
          viewModel.pvComparisonData!.dataPoints
              .where((point) => point.values.containsKey(pvString.name))
              .map((point) => FlSpot(point.timestamp.millisecondsSinceEpoch.toDouble(), point.values[pvString.name]!))
              .toList();

      lineBars.add(
        LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: AppConstants.chartLineThickness, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false)),
      );
    }

    return lineBars;
  }

  Widget _buildMeasurementTypeDropdown(DeviceHistoryViewModel viewModel) {
    return DropdownButtonFormField<PVMeasurementType>(
      value: viewModel.selectedMeasurementType,
      items:
          PVMeasurementType.values.map((type) {
            return DropdownMenuItem(value: type, child: Text(_getMeasurementTypeName(type)));
          }).toList(),
      onChanged: (type) => viewModel.setSelectedMeasurementType(type!),
      decoration: const InputDecoration(
        labelText: 'Ölçüm Türü',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
      ),
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

  Widget _buildDatePicker(DeviceHistoryViewModel viewModel) {
    return InkWell(
      onTap: () => _selectDate(context, viewModel),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tarih',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(DateFormat('dd/MM/yyyy').format(viewModel.selectedDate)), const Icon(Icons.calendar_today, size: AppConstants.iconSizeMedium)],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DeviceHistoryViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: viewModel.selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.setSelectedDate(picked);
    }
  }
}
