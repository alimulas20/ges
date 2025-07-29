import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../global/constant/app_constants.dart';
import '../models/plant_production_model.dart';
import '../services/plant_service.dart';

import '../../../global/widgets/production_chart.dart';
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(viewModel.errorMessage!), const SizedBox(height: AppConstants.paddingExtraLarge), ElevatedButton(onPressed: () => viewModel.refresh(), child: const Text('Yenile'))],
                ),
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

                  // Production chart
                  if (viewModel.productionData != null) ProductionChart(dataPoints: viewModel.productionData!.dataPoints, bottomDescription: viewModel.bottomDescription),
                ],
              ),
            );
          },
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

  Future<void> _selectDate(BuildContext context, PlantProductionViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: viewModel.selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.setSelectedDate(picked);
    }
  }
}
