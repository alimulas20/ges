import 'package:flutter/material.dart' hide DatePickerMode;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/widgets/custom_date_picker.dart'; // Yeni eklediğimiz import
import '../../../global/widgets/error_display_widget.dart';
import '../../../global/widgets/production_chart.dart';
import '../models/plant_production_model.dart';
import '../services/plant_service.dart';
import '../viewmodels/plant_production_viewmodel.dart';

class PlantProductionView extends StatefulWidget {
  final int plantId;

  const PlantProductionView({super.key, required this.plantId});

  @override
  State<PlantProductionView> createState() => _PlantProductionViewState();
}

class _PlantProductionViewState extends State<PlantProductionView> {
  late final PlantProductionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PlantProductionViewModel(PlantService(), widget.plantId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Üretim Verileri'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.refresh())], toolbarHeight: AppConstants.appBarHeight),
        body: Consumer<PlantProductionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.productionData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return ErrorDisplayWidget(
                errorMessage: viewModel.errorMessage!,
                onRetry: () => viewModel.refresh(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time period selector and date picker
                  _buildControls(viewModel),
                  const SizedBox(height: AppConstants.paddingUltraLarge),

                  // Total production card - TABLONUN ÜSTÜNDE GÖRÜNTÜLE
                  if (viewModel.productionData != null) _buildTotalProductionCard(viewModel.productionData!, viewModel.predictedTotalEnergy, viewModel.selectedDate, viewModel.selectedTimePeriod),

                  const SizedBox(height: AppConstants.paddingUltraLarge),

                  // Production chart
                  if (viewModel.productionData != null)
                    ProductionChart(
                      dataPoints: viewModel.productionData!.dataPoints,
                      predictionDataPoints: viewModel.predictionData,
                      bottomDescription: viewModel.bottomDescription,
                      timePeriod: viewModel.selectedTimePeriod,
                      unit: viewModel.productionData?.unit ?? "",
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Toplam üretim kartı
  Widget _buildTotalProductionCard(PlantProductionDTO productionData, double? predictedTotalEnergy, DateTime selectedDate, ProductionTimePeriod timePeriod) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), boxShadow: AppConstants.elevatedShadow),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Toplam Üretim', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  Text(
                    productionData.totalProduction.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text("kWh", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
              // Tahmin edilen üretim (sadece bugün ve prediction varsa)
              if (predictedTotalEnergy != null) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                const Divider(),
                const SizedBox(height: AppConstants.paddingMedium),
                Text('Bugün Tahmin Edilen Üretim', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.orange)),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    Text(predictedTotalEnergy.toStringAsFixed(2), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text("kWh", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orange.withOpacity(0.8))),
                  ],
                ),
              ],
              const SizedBox(height: AppConstants.paddingSmall),
              //Text(_getTimePeriodDescription(timePeriod, selectedDate), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(PlantProductionViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Time period dropdown
        DropdownButtonFormField<ProductionTimePeriod>(
          value: viewModel.selectedTimePeriod,
          items: ProductionTimePeriod.values.map((period) => DropdownMenuItem(value: period, child: Text(period.displayName))).toList(),
          onChanged: (period) => viewModel.setSelectedTimePeriod(period!),
          decoration: const InputDecoration(labelText: 'Zaman Periyodu', border: OutlineInputBorder()),
        ),
        const SizedBox(height: AppConstants.paddingLarge),

        // Date picker - hidden for lifetime
        if (viewModel.selectedTimePeriod != ProductionTimePeriod.lifetime) _buildDatePicker(viewModel),
      ],
    );
  }

  Widget _buildDatePicker(PlantProductionViewModel viewModel) {
    String dateText;

    switch (viewModel.selectedTimePeriod) {
      case ProductionTimePeriod.daily:
        dateText = DateFormat('dd/MM/yyyy').format(viewModel.selectedDate);
        break;
      case ProductionTimePeriod.monthly:
        dateText = DateFormat('MMMM yyyy').format(viewModel.selectedDate);
        break;
      case ProductionTimePeriod.yearly:
        dateText = viewModel.selectedDate.year.toString();
        break;
      case ProductionTimePeriod.lifetime:
        dateText = '';
        break;
    }

    return InkWell(
      onTap: () => _selectDate(context, viewModel),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tarih',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(dateText), const Icon(Icons.calendar_today, size: AppConstants.iconSizeMedium)]),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, PlantProductionViewModel viewModel) async {
    DatePickerMode mode;

    switch (viewModel.selectedTimePeriod) {
      case ProductionTimePeriod.daily:
        mode = DatePickerMode.day;
        break;
      case ProductionTimePeriod.monthly:
        mode = DatePickerMode.month;
        break;
      case ProductionTimePeriod.yearly:
        mode = DatePickerMode.year;
        break;
      case ProductionTimePeriod.lifetime:
        return; // Lifetime için date picker göstermiyoruz
    }

    final DateTime? picked = await CustomDatePicker.showCustomDatePicker(context: context, initialDate: viewModel.selectedDate, mode: mode, firstDate: DateTime(2000), lastDate: DateTime.now());

    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.setSelectedDate(picked);
    }
  }
}
