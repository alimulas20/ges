// views/device_setup_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/app_constants.dart';
import 'package:smart_ges_360/global/widgets/custom_navbar.dart';
import 'package:smart_ges_360/pages/alarm/views/alarm_view.dart';

import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';
import '../viewmodel/device_setup_list_view_model.dart';
import 'device_details_view.dart';
import 'device_history_view.dart';

class DeviceSetupListView extends StatefulWidget {
  const DeviceSetupListView({super.key});

  @override
  State<DeviceSetupListView> createState() => _DeviceSetupListViewState();
}

class _DeviceSetupListViewState extends State<DeviceSetupListView> {
  late final DeviceSetupListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceSetupListViewModel(DeviceSetupService());
    _viewModel.fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inverterler', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchDevices())],
        ),
        body: Consumer<DeviceSetupListViewModel>(
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
                    ElevatedButton(onPressed: () => viewModel.fetchDevices(), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            if (viewModel.devices.isEmpty) {
              return const Center(child: Text('Inverter bulunamadı'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: viewModel.devices.length,
              itemBuilder: (context, index) {
                final device = viewModel.devices[index];
                return _buildDeviceCard(device, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeviceCard(DeviceSetupWithReadingDTO device, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall, horizontal: AppConstants.paddingMedium),
      elevation: AppConstants.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CustomNavbar(
                    pages: [
                      DeviceDetailsView(deviceSetupId: device.deviceSetupId),
                      DeviceHistoryView(deviceSetupId: device.deviceSetupId),
                      AlarmsPage(deviceSetupId: device.deviceSetupId), // PV Comparison page
                      Container(color: Colors.white), // Empty page 4
                    ],
                    icons: const [Icon(Icons.info), Icon(Icons.history), Icon(Icons.show_chart), Icon(Icons.settings)],
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(device.deviceName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Chip(label: Text(device.deviceType), backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1)),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text('Kurulum: ${device.setupName}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppConstants.paddingSmall),
              Text('Santral: ${device.plantName}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppConstants.paddingSmall),
              if (device.latestReading != null) ...[const Divider(), _buildReadingInfo(device.latestReading!, context)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingInfo(InverterReadingDTO reading, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Son Okuma: ${reading.createdDate.toString()}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            _buildReadingItem(Icons.bolt, '${reading.activePower.toStringAsFixed(2)} kW', context),
            _buildReadingItem(Icons.today, '${reading.yieldToday.toStringAsFixed(2)} kWh', context),
            _buildReadingItem(Icons.stacked_line_chart, '${reading.totalYield.toStringAsFixed(2)} kWh', context),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingItem(IconData icon, String text, BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppConstants.iconSizeSmall, color: Theme.of(context).primaryColor),
          const SizedBox(width: AppConstants.paddingSmall),
          Flexible(child: Text(text, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
