// views/device_setup_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar/global/constant/type_constants.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/widgets/custom_navbar.dart';
import '../../alarm/views/alarm_view.dart';
import '../model/device_setup_with_reading_dto.dart';
import '../service/device_setup_service.dart';
import '../viewmodel/device_setup_list_view_model.dart';
import 'device_history_view.dart';
import 'device_info_view.dart';
import 'device_reading_view.dart';

class DeviceSetupListView extends StatefulWidget {
  const DeviceSetupListView({super.key, this.plantId});
  final int? plantId;

  @override
  State<DeviceSetupListView> createState() => _DeviceSetupListViewState();
}

class _DeviceSetupListViewState extends State<DeviceSetupListView> {
  late final DeviceSetupListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceSetupListViewModel(DeviceSetupService());

    _viewModel.fetchDevices(widget.plantId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inverterler', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),

          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchDevices(widget.plantId))],
          toolbarHeight: AppConstants.appBarHeight,
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
                    ElevatedButton(onPressed: () => viewModel.fetchDevices(widget.plantId), child: const Text('Yenile')),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withOpacity(0.8)]),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 0),
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 16), spreadRadius: 0),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (device.deviceType == DeviceType.inverter) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CustomNavbar(
                        pages: [
                          DeviceReadingsView(deviceSetupId: device.deviceSetupId),
                          DeviceHistoryView(deviceSetupId: device.deviceSetupId),
                          AlarmsPage(deviceSetupId: device.deviceSetupId),
                          DeviceInfoView(deviceSetupId: device.deviceSetupId),
                        ],
                        tabs: const [
                          Tab(icon: Icon(Icons.bolt), text: "Anlık Bilgi"),
                          Tab(icon: Icon(Icons.show_chart), text: "İstatistikler"),
                          Tab(icon: Icon(Icons.notifications), text: "Alarmlar"),
                          Tab(icon: Icon(Icons.info), text: "Temel Bilgiler"),
                        ],
                      ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(device, context),
                const SizedBox(height: 20),
                _buildDeviceInfo(device, context),
                if (device.latestReading != null) ...[const SizedBox(height: 20), _buildDivider(context), const SizedBox(height: 20), _buildReadingInfo(device.latestReading!, context)],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(DeviceSetupWithReadingDTO device, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.deviceName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(device.deviceType, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        _buildStatusChip(device, context),
      ],
    );
  }

  Widget _buildDeviceInfo(DeviceSetupWithReadingDTO device, BuildContext context) {
    return Column(children: [_buildInfoRow(Icons.build, 'Kurulum', device.setupName, context), const SizedBox(height: 12), _buildInfoRow(Icons.location_on, 'Santral', device.plantName, context)]);
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Theme.of(context).dividerColor.withOpacity(0.3), Colors.transparent])));
  }

  Widget _buildReadingInfo(InverterReadingDTO reading, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Theme.of(context).primaryColor.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              'Son Okuma: ${_formatDateTime(reading.createdDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildModernReadingItem(Icons.bolt, 'Aktif Güç', '${reading.activePower.toStringAsFixed(2)} kW', Colors.orange, context)),
            const SizedBox(width: 12),
            Expanded(child: _buildModernReadingItem(Icons.today, 'Günlük Üretim', '${reading.yieldToday.toStringAsFixed(2)} kWh', Colors.green, context)),
          ],
        ),
        const SizedBox(height: 12),
        _buildModernReadingItem(Icons.stacked_line_chart, 'Toplam Üretim', '${reading.totalYield.toStringAsFixed(2)} kWh', Colors.blue, context),
      ],
    );
  }

  Widget _buildModernReadingItem(IconData icon, String label, String value, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2), width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildStatusChip(DeviceSetupWithReadingDTO device, BuildContext context) {
    String statusText = 'Çalışıyor';
    Color statusColor = Colors.green;

    if (device.latestReading != null) {
      final statusName = device.latestReading!.statusName;
      if (statusName.isNotEmpty) {
        statusText = statusName;
        statusColor = statusName.toLowerCase() == 'çalışıyor' ? Colors.green : Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
