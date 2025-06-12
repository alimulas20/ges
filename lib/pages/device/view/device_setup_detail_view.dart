import 'package:flutter/material.dart';

import '../model/device_setup_dto.dart';

class DeviceSetupDetailView extends StatelessWidget {
  final DeviceSetupDTO deviceSetup;

  const DeviceSetupDetailView({super.key, required this.deviceSetup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(deviceSetup.deviceName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Setup Name', deviceSetup.setupName),
            _buildDetailRow('Plant Name', deviceSetup.plantName),
            _buildDetailRow('Device Type', deviceSetup.deviceType),
            _buildDetailRow('Slave Number', deviceSetup.slaveNumber.toString()),
            if (deviceSetup.warrantyExpirationDate != null) _buildDetailRow('Warranty Expiration', _formatDateTime(deviceSetup.warrantyExpirationDate!)),
            _buildDetailRow('Daily Production', '${deviceSetup.dailyProductionKWh} kWh'),
            _buildDetailRow('Current Power', '${deviceSetup.currentActivePowerKW} kW'),
            _buildDetailRow('Software Version', deviceSetup.softwareVersion),
            if (deviceSetup.lastUpdateTime != null) _buildDetailRow('Last Update', _formatDateTime(deviceSetup.lastUpdateTime!)),
            _buildDetailRow('PV String Count', deviceSetup.pvStringCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text(value))]),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
