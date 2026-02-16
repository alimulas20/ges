import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/utils/alert_utils.dart';
import '../../../global/widgets/alarm_detail_dialog.dart';
import '../../../global/widgets/error_display_widget.dart';
import '../../../global/widgets/solar_connection_animation.dart';
import '../../alarm/model/alarm_dto.dart';
import '../../alarm/service/alarm_service.dart';
import '../models/plant_status_dto.dart';
import '../services/plant_service.dart';
import '../viewmodels/plant_status_viewmodel.dart';

class PlantStatusView extends StatefulWidget {
  final int plantId;

  const PlantStatusView({super.key, required this.plantId});

  @override
  State<PlantStatusView> createState() => _PlantStatusViewState();
}

class _PlantStatusViewState extends State<PlantStatusView> {
  late final PlantStatusViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PlantStatusViewModel(PlantService(), AlarmService(), widget.plantId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tesis Durumu'), toolbarHeight: AppConstants.appBarHeight, actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.refresh())]),
        body: Consumer<PlantStatusViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return ErrorDisplayWidget(errorMessage: viewModel.errorMessage!, onRetry: () => viewModel.refresh());
            }

            if (viewModel.plantStatus == null) {
              return const Center(child: Text('Tesis bulunamadı'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alarm List Section
                  if (viewModel.displayAlarms.isNotEmpty) ...[_buildAlarmSection(viewModel.displayAlarms), const SizedBox(height: AppConstants.paddingLarge)],

                  // Animation and Status Section with PV Generation overlay
                  _buildStatusSectionWithPVGeneration(viewModel),

                  const SizedBox(height: AppConstants.paddingHuge),

                  // Production Information Cards
                  const SizedBox(height: AppConstants.paddingLarge),

                  // New Plant Status Information Cards
                  if (viewModel.plantStatus != null) _buildNewStatusInfoCards(viewModel.plantStatus!),

                  // Add bottom padding to prevent overflow
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlarmSection(List<AlarmDto> alarms) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), border: Border.all(color: Colors.red[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 20),
              const SizedBox(width: AppConstants.paddingSmall),
              Text('Aktif Alarmlar (${alarms.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[600], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...alarms.take(3).map((alarm) => _buildAlarmItem(alarm)),
          if (alarms.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
              child: Text('+${alarms.length - 3} alarm daha...', style: TextStyle(color: Colors.red[600], fontSize: AppConstants.fontSizeSmall, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  Widget _buildAlarmItem(AlarmDto alarm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: InkWell(
        onTap: () => _showAlarmDetails(alarm.id),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium), border: Border.all(color: Colors.red[100]!)),
          child: Row(
            children: [
              Container(width: 4, height: 40, decoration: BoxDecoration(color: _getLevelColor(alarm.level ?? ''), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alarm.name ?? 'Bilinmeyen Alarm', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeMedium)),
                    const SizedBox(height: 2),
                    Text(alarm.source, style: TextStyle(color: Colors.grey[600], fontSize: AppConstants.fontSizeSmall)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSectionWithPVGeneration(PlantStatusViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), boxShadow: AppConstants.cardShadow),
      child: Column(
        children: [
          // Plant Name and Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(viewModel.plantStatus!.plantName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: viewModel.isOnline ? Colors.green : Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          viewModel.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                          style: TextStyle(color: viewModel.isOnline ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: AppConstants.fontSizeMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Solar Connection Animation
          SolarConnectionAnimation(isOnline: viewModel.isOnline, productionValue: viewModel.plantStatus!.currentPVGeneration, unit: 'kW'),
        ],
      ),
    );
  }

  Widget _buildNewStatusInfoCards(PlantStatusDto plantStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tesis Durumu', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.paddingMedium),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingMedium,
          mainAxisSpacing: AppConstants.paddingMedium,
          childAspectRatio: 1.5,
          children: [
            _buildNewInfoCard('Günlük Üretim', '${plantStatus.todayProduction.toStringAsFixed(2)} kWh', Icons.solar_power, Colors.orange),
            _buildNewInfoCard('Toplam Üretim', '${(plantStatus.totalProduction / 1000).toStringAsFixed(2)} MWh', Icons.trending_up, Colors.green),
            _buildNewInfoCard('Tesis Kapasitesi(DC)', '${plantStatus.totalStringCapacityKWp.toStringAsFixed(2)} kWp', Icons.battery_charging_full, Colors.blue),
            _buildNewInfoCard('Tesis Kapasitesi(AC)', '${plantStatus.inverterNominalPower.toStringAsFixed(2)} kW', Icons.speed, Colors.purple),
            _buildNewInfoCard('Anlık Üretim', '${plantStatus.currentPVGeneration.toStringAsFixed(2)} kW', Icons.flash_on, Colors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildNewInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), boxShadow: AppConstants.cardShadow),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: AppConstants.fontSizeSmall, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _showAlarmDetails(int alarmId) async {
    try {
      final alarm = await _viewModel.getAlarmDetails(alarmId);
      if (mounted) {
        await AlarmDetailDialog.show(context, alarm);
      }
    } catch (e) {
      if (mounted) {
        AlertUtils.showError(context, title: 'Alarm Detayları Yüklenemedi', error: e);
      }
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'major':
        return Colors.red;
      case 'minor':
        return Colors.orange;
      case 'warning':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}
