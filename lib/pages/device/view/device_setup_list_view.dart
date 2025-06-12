import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/device_setup_dto.dart';
import '../service/device_setup_service.dart';
import '../viewmodel/device_setup_list_viewmodel.dart';
import 'device_setup_detail_view.dart';

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
    _viewModel.fetchDeviceSetups();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Device Setups'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchDeviceSetups())]),
        body: Consumer<DeviceSetupListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(viewModel.errorMessage!), const SizedBox(height: 16), ElevatedButton(onPressed: () => viewModel.fetchDeviceSetups(), child: const Text('Retry'))],
                ),
              );
            }

            if (viewModel.deviceSetups.isEmpty) {
              return const Center(child: Text('No device setups found'));
            }

            return ListView.builder(
              itemCount: viewModel.deviceSetups.length,
              itemBuilder: (context, index) {
                final setup = viewModel.deviceSetups[index];
                return _buildDeviceSetupCard(setup);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeviceSetupCard(DeviceSetupDTO setup) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceSetupDetailView(deviceSetup: setup)));
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(setup.deviceName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Setup: ${setup.setupName}'),
              Text('Plant: ${setup.plantName}'),
              Text('Device Type: ${setup.deviceType}'),
              Text('PV Strings: ${setup.pvStringCount}'),
              if (setup.lastUpdateTime != null) Text('Last Update: ${_formatDateTime(setup.lastUpdateTime!)}'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
