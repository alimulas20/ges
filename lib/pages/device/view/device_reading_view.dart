// views/device_readings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';
import '../viewmodel/device_reading_view_model.dart';

class DeviceReadingsView extends StatefulWidget {
  final int deviceSetupId;

  const DeviceReadingsView({super.key, required this.deviceSetupId});

  @override
  State<DeviceReadingsView> createState() => _DeviceReadingsViewState();
}

class _DeviceReadingsViewState extends State<DeviceReadingsView> {
  late final DeviceReadingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceReadingsViewModel(DeviceSetupService(), widget.deviceSetupId);
    _viewModel.fetchDeviceReadings();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Anlık Okumalar'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _viewModel.fetchDeviceReadings)],
          toolbarHeight: AppConstants.appBarHeight,
        ),
        body: Consumer<DeviceReadingsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.deviceReadings == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.errorMessage!),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    ElevatedButton(onPressed: _viewModel.fetchDeviceReadings, child: const Text('Yenile')),
                  ],
                ),
              );
            }

            final readings = viewModel.deviceReadings;
            if (readings == null) {
              return const Center(child: Text('Okuma bilgisi bulunamadı'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
              child: Column(
                children: [
                  if (readings.latestReading != null) _buildReadingCard(readings.latestReading!, context),
                  if (readings.pvGenerations.isNotEmpty) _buildPVGenerationsCard(readings.pvGenerations, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReadingCard(InverterReadingDetailDTO reading, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Son Okuma Bilgileri', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow('Zaman', reading.createdDate.toLocal().toString(), context),
            _buildInfoRow('Aktif Güç', '${reading.activePower.toStringAsFixed(2)} kW', context),
            _buildInfoRow('Günlük Üretim', '${reading.yieldToday.toStringAsFixed(2)} kWh', context),
            _buildInfoRow('Toplam Üretim', '${reading.totalYield.toStringAsFixed(2)} kWh', context),
            _buildInfoRow('Şebeke Frekansı', '${reading.gridFrequency.toStringAsFixed(2)} Hz', context),
            _buildInfoRow('İç Sıcaklık', '${reading.internalTemperature.toStringAsFixed(2)} °C', context),
          ],
        ),
      ),
    );
  }

  Widget _buildPVGenerationsCard(List<PVGenerationDTO> generations, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PV Üretim Bilgileri', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...generations.map(
              (g) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.pvStringTechnicalName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildInfoRow('Voltaj', '${g.voltage.toStringAsFixed(2)} V', context),
                  _buildInfoRow('Akım', '${g.current.toStringAsFixed(2)} A', context),
                  _buildInfoRow('Güç', '${g.power.toStringAsFixed(2)} W', context),
                  _buildInfoRow('Zaman', g.createdDate.toLocal().toString(), context),
                  if (g != generations.last) const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(children: [Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(flex: 3, child: Text(value))]),
    );
  }
}
