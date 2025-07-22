import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/AppConstants.dart';

import '../service/device_setup_service.dart';
import '../viewmodel/device_history_view_model.dart';

class DeviceHistoryView extends StatefulWidget {
  final int deviceSetupId;

  const DeviceHistoryView({super.key, required this.deviceSetupId});

  @override
  State<DeviceHistoryView> createState() => _DeviceHistoryViewState();
}

class _DeviceHistoryViewState extends State<DeviceHistoryView> {
  late final DeviceHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceHistoryViewModel(DeviceSetupService(), widget.deviceSetupId);
    _viewModel.fetchAttributes();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geçmiş Veriler', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchAttributes())],
        ),
        body: Consumer<DeviceHistoryViewModel>(
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
                    ElevatedButton(onPressed: () => _viewModel.fetchAttributes(), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Attribute selection
                Padding(padding: const EdgeInsets.all(AppConstants.paddingMedium), child: Text('Özellik Seçimi', style: Theme.of(context).textTheme.titleMedium)),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.attributes.length,
                    itemBuilder: (context, index) {
                      final attribute = viewModel.attributes[index];
                      return CheckboxListTile(
                        title: Text(attribute.name),
                        subtitle: Text('${attribute.unit} - ${attribute.description}'),
                        value: viewModel.selectedAttributes.contains(attribute.key),
                        onChanged: (value) {
                          if (value == true) {
                            _viewModel.selectAttribute(attribute.key);
                          } else {
                            _viewModel.deselectAttribute(attribute.key);
                          }
                        },
                      );
                    },
                  ),
                ),
                // Graph would be displayed here
                if (viewModel.selectedAttributes.isNotEmpty)
                  Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(child: Text('Grafik burada gösterilecek (Seçilen özellikler: ${viewModel.selectedAttributes.join(', ')})', textAlign: TextAlign.center)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
