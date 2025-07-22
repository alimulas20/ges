// views/device_details_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/AppConstants.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';
import '../viewmodel/device_details_view_model.dart';

class DeviceDetailsView extends StatefulWidget {
  final int deviceSetupId;

  const DeviceDetailsView({super.key, required this.deviceSetupId});

  @override
  State<DeviceDetailsView> createState() => _DeviceDetailsViewState();
}

class _DeviceDetailsViewState extends State<DeviceDetailsView> {
  late final DeviceDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceDetailsViewModel(DeviceSetupService(), widget.deviceSetupId);
    _viewModel.fetchDeviceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inverter Detayları', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchDeviceDetails())],
        ),
        body: Consumer<DeviceDetailsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSuperLarge), child: Text(viewModel.errorMessage!, textAlign: TextAlign.center)),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    ElevatedButton(onPressed: () => viewModel.fetchDeviceDetails(), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            if (viewModel.deviceDetails == null) {
              return const Center(child: Text('Inverter detayları bulunamadı'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  _buildGeneralInfoCard(viewModel.deviceDetails!, context),
                  if (viewModel.deviceDetails!.latestReading != null) _buildReadingCard(viewModel.deviceDetails!.latestReading!, context),
                  if (viewModel.deviceDetails!.pvGenerations != null) _buildPVGenerationCard(viewModel.deviceDetails!.pvGenerations!, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGeneralInfoCard(DeviceDetailsDTO device, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Genel Bilgiler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow('Inverter Adı', device.deviceName, context),
            _buildInfoRow('Kurulum Adı', device.setupName, context),
            _buildInfoRow('Santral Adı', device.plantName, context),
            _buildInfoRow('Slave Numarası', device.slaveNumber.toString(), context),
            if (device.warrantyExpirationDate != null) _buildInfoRow('Garanti Bitiş', device.warrantyExpirationDate!.toLocal().toString(), context),
            _buildInfoRow('Cihaz Türü', device.deviceType, context),
            _buildInfoRow('Yazılım Versiyonu', device.softwareVersion, context),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(InverterReadingDTO reading, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Son Okuma Bilgileri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow('Okuma Zamanı', reading.createdDate.toLocal().toString(), context),
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

  Widget _buildPVGenerationCard(PVGenerationDTO pv, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PV Üretim Bilgileri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow('PV String', pv.pvStringName, context),
            _buildInfoRow('Okuma Zamanı', pv.createdDate.toLocal().toString(), context),
            _buildInfoRow('Voltaj', '${pv.voltage.toStringAsFixed(2)} V', context),
            _buildInfoRow('Akım', '${pv.current.toStringAsFixed(2)} A', context),
            _buildInfoRow('Güç', '${pv.power.toStringAsFixed(2)} W', context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
