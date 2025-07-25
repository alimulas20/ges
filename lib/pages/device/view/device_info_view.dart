// views/device_info_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/app_constants.dart';

import '../service/device_setup_service.dart';
import '../viewmodel/device_info_view_model.dart';

class DeviceInfoView extends StatelessWidget {
  final int deviceSetupId;

  const DeviceInfoView({super.key, required this.deviceSetupId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeviceInfoViewModel(DeviceSetupService(), deviceSetupId),
      child: Consumer<DeviceInfoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(viewModel.errorMessage!), ElevatedButton(onPressed: viewModel.fetchDeviceInfo, child: const Text('Yenile'))]),
            );
          }

          final deviceInfo = viewModel.deviceInfo;
          if (deviceInfo == null) {
            return const Center(child: Text('Cihaz bilgisi bulunamadı'));
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cihaz Bilgileri', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  _buildInfoRow('Cihaz Adı', deviceInfo.deviceName, context),
                  _buildInfoRow('Kurulum Adı', deviceInfo.setupName, context),
                  _buildInfoRow('Santral Adı', deviceInfo.plantName, context),
                  _buildInfoRow('Adres', deviceInfo.plantAddress, context),
                  _buildInfoRow('Slave No', deviceInfo.slaveNumber.toString(), context),
                  if (deviceInfo.warrantyExpirationDate != null) _buildInfoRow('Garanti Bitiş', deviceInfo.warrantyExpirationDate!.toLocal().toString(), context),
                  _buildInfoRow('Cihaz Türü', deviceInfo.deviceType, context),
                  _buildInfoRow('Yazılım Versiyonu', deviceInfo.softwareVersion, context),
                ],
              ),
            ),
          );
        },
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
