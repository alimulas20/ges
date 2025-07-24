import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/app_constants.dart';
import 'package:smart_ges_360/global/managers/dio_service.dart';

import '../model/alarm_dto.dart';
import '../service/alarm_service.dart';
import '../viewmodels/alarm_viewmodel.dart';

// Main Alarms Page
class AlarmsPage extends StatefulWidget {
  final int? deviceSetupId;

  const AlarmsPage({super.key, this.deviceSetupId});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _alarmLevels = ['Major', 'Minor', 'Warning'];
  final Set<String> _selectedLevels = {'Major', 'Minor', 'Warning'};
  int? _selectedPlantId;
  int? _selectedDeviceSetupId;
  DateTime? _selectedDate;
  late final AlarmsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = AlarmsViewModel(AlarmService());
    _selectedDeviceSetupId = widget.deviceSetupId;
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    await _viewModel.fetchAlarms(
      plantId: _selectedPlantId,
      deviceSetupId: _selectedDeviceSetupId,
      selectedDate: _selectedDate,
      activeOnly: _tabController.index == 0,
      levels: _selectedLevels.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarmlar', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Aktif Alarmlar'), Tab(text: 'Geçmiş Alarmlar')], onTap: (index) => _loadAlarms()),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ChangeNotifierProvider.value(
              value: _viewModel,
              child: Consumer<AlarmsViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text(viewModel.errorMessage!), const SizedBox(height: AppConstants.paddingExtraLarge), ElevatedButton(onPressed: _loadAlarms, child: const Text('Yenile'))],
                      ),
                    );
                  }

                  if (viewModel.alarms.isEmpty) {
                    return const Center(child: Text('Alarm bulunamadı'));
                  }

                  return RefreshIndicator(
                    onRefresh: _loadAlarms,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: viewModel.alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = viewModel.alarms[index];
                        return _buildAlarmCard(alarm, context);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          if (widget.deviceSetupId == null) ...[
            // Only show plant and inverter filters when not coming from device details
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Tesis Seçiniz', border: OutlineInputBorder()),
              value: _selectedPlantId,
              items: _viewModel.plants.map((plant) => DropdownMenuItem(value: plant.id, child: Text(plant.name))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlantId = value;
                  _selectedDeviceSetupId = null;
                });
                _loadAlarms();
              },
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Inverter Seçiniz', border: OutlineInputBorder()),
              value: _selectedDeviceSetupId,
              items:
                  _viewModel.devices
                      .where((device) => _selectedPlantId == null || device.plantId == _selectedPlantId)
                      .map((device) => DropdownMenuItem(value: device.id, child: Text(device.name)))
                      .toList(),
              onChanged: (value) {
                setState(() => _selectedDeviceSetupId = value);
                _loadAlarms();
              },
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
          _buildLevelFilterChips(),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null ? 'Tüm Tarihler' : DateFormat('dd.MM.yyyy').format(_selectedDate!)),
                  onPressed: () async {
                    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      _loadAlarms();
                    }
                  },
                ),
              ),
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _selectedDate = null);
                    _loadAlarms();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alarm Seviyesi', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: AppConstants.paddingSmall,
          children:
              _alarmLevels.map((level) {
                final isSelected = _selectedLevels.contains(level);
                return FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLevels.add(level);
                      } else {
                        _selectedLevels.remove(level);
                      }
                    });
                    _loadAlarms();
                  },
                  selectedColor: _getLevelColor(level).withOpacity(0.2),
                  checkmarkColor: _getLevelColor(level),
                  labelStyle: TextStyle(color: isSelected ? _getLevelColor(level) : Colors.black),
                );
              }).toList(),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Major':
        return Colors.red;
      case 'Minor':
        return Colors.orange;
      case 'Warning':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAlarmCard(AlarmDto alarm, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: () => _showAlarmDetails(alarm.id, context),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 40, color: _getLevelColor(alarm.level), margin: const EdgeInsets.only(right: AppConstants.paddingMedium)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alarm.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(alarm.plantName, style: Theme.of(context).textTheme.bodySmall),
                        if (alarm.deviceSetupName != null) Text(alarm.deviceSetupName!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(alarm.level, style: TextStyle(color: _getLevelColor(alarm.level), fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(DateFormat('dd.MM.yyyy HH:mm').format(alarm.occuredAt), style: Theme.of(context).textTheme.bodySmall),
                      if (alarm.clearedAt != null) Text('Temizlenme: ${DateFormat('dd.MM.yyyy HH:mm').format(alarm.clearedAt!)}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAlarmDetails(int alarmId, BuildContext context) async {
    final alarm = await _viewModel.getAlarmDetails(alarmId);
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Alarm Detayı - ${alarm.level}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Kod', alarm.alarmCode),
                  _buildDetailRow('Hata', alarm.name),
                  _buildDetailRow('Açıklama', alarm.description),
                  _buildDetailRow('Kaynak', alarm.source),
                  _buildDetailRow('Tesis', alarm.plantName),
                  if (alarm.deviceSetupName != null) _buildDetailRow('Inverter', alarm.deviceSetupName!),
                  _buildDetailRow('Oluşma Zamanı', DateFormat('dd.MM.yyyy HH:mm').format(alarm.occuredAt)),
                  if (alarm.clearedAt != null) _buildDetailRow('Temizlenme Zamanı', DateFormat('dd.MM.yyyy HH:mm').format(alarm.clearedAt!)),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat'))],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))), const SizedBox(width: AppConstants.paddingMedium), Expanded(child: Text(value))],
      ),
    );
  }
}
