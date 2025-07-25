// views/device_readings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/extensions/date_time_extensions.dart';

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
                  if (readings.pvGenerations.isNotEmpty) _buildPVGenerationsTable(readings.pvGenerations, context),
                  const SizedBox(height: AppConstants.paddingLarge),
                  if (readings.latestReading != null) _buildInverterReadingCard(readings.latestReading!, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPVGenerationsTable(List<PVGenerationDTO> generations, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PV Üretim Bilgileri', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppConstants.paddingMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: AppConstants.paddingLarge,
                columns: const [DataColumn(label: Text('PV Adı')), DataColumn(label: Text('Voltaj (V)')), DataColumn(label: Text('Akım (A)')), DataColumn(label: Text('Güç (W)'))],
                rows:
                    generations.map((g) {
                      return DataRow(
                        cells: [
                          DataCell(Text(g.pvStringTechnicalName)),
                          DataCell(Text(g.voltage.toStringAsFixed(2))),
                          DataCell(Text(g.current.toStringAsFixed(2))),
                          DataCell(Text(g.power.toStringAsFixed(2))),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInverterReadingCard(InverterReadingDetailDTO reading, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inverter Okuma Bilgileri', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildInfoRow('Okuma Zamanı', reading.createdDate.fullDateWithTime, context),

            // Phase Voltages and Currents
            _buildSectionTitle('Faz Voltaj ve Akımları', context),
            _buildInfoRow('A Faz Voltaj', '${reading.phaseAV.toStringAsFixed(2)} V', context),
            _buildInfoRow('A Faz Akım', '${reading.phaseAA.toStringAsFixed(2)} A', context),
            _buildInfoRow('B Faz Voltaj', '${reading.phaseBV.toStringAsFixed(2)} V', context),
            _buildInfoRow('B Faz Akım', '${reading.phaseBA.toStringAsFixed(2)} A', context),
            _buildInfoRow('C Faz Voltaj', '${reading.phaseCV.toStringAsFixed(2)} V', context),
            _buildInfoRow('C Faz Akım', '${reading.phaseCA.toStringAsFixed(2)} A', context),

            // Power Information
            _buildSectionTitle('Güç Bilgileri', context),
            _buildInfoRow('Aktif Güç', '${reading.activePower.toStringAsFixed(2)} kW', context),
            _buildInfoRow('Reaktif Güç', '${reading.reactivePower.toStringAsFixed(2)} kVAr', context),
            _buildInfoRow('Güç Faktörü', reading.powerFactor.toStringAsFixed(2), context),

            // Energy Production
            _buildSectionTitle('Enerji Üretimi', context),
            _buildInfoRow('Günlük Üretim', '${reading.yieldToday.toStringAsFixed(2)} kWh', context),
            _buildInfoRow('Toplam Üretim', '${reading.totalYield.toStringAsFixed(2)} kWh', context),

            // System Information
            _buildSectionTitle('Sistem Bilgileri', context),
            _buildInfoRow('Şebeke Frekansı', '${reading.gridFrequency.toStringAsFixed(2)} Hz', context),
            _buildInfoRow('Cihaz Durumu', reading.deviceStatus.toString(), context),
            _buildInfoRow('İç Sıcaklık', '${reading.internalTemperature.toStringAsFixed(2)} °C', context),
            _buildInfoRow('İzolasyon Direnci', '${reading.insulationResistance.toStringAsFixed(2)} MΩ', context),

            // Operation Times
            _buildSectionTitle('Çalışma Zamanları', context),
            _buildInfoRow('Başlangıç Zamanı', reading.startupTime.fullDateWithTime, context),
            _buildInfoRow('Kapanış Zamanı', reading.shutDownTime.fullDateWithTime, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.paddingMedium, bottom: AppConstants.paddingSmall),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(flex: 3, child: Text(value, style: const TextStyle(fontFamily: 'RobotoMono')))],
      ),
    );
  }
}
