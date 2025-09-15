import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../../device/service/device_setup_service.dart';
import '../../plant/services/plant_service.dart';
import '../model/alarm_dto.dart';
import '../service/alarm_service.dart';
import '../viewmodels/alarm_viewmodel.dart';

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
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Geçmiş alarmlar default
    _viewModel = AlarmsViewModel(AlarmService(), PlantService(), DeviceSetupService());
    _selectedDeviceSetupId = widget.deviceSetupId;
    _selectedDate = null; // Tarih seçimi default boş
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    await _viewModel.fetchAlarms(
      deviceSetupId: _selectedDeviceSetupId,
      plantId: _selectedPlantId,
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
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Filtreleri Gizle' : 'Filtreleri Göster',
          ),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Aktif Alarmlar'), Tab(text: 'Geçmiş Alarmlar')], onTap: (index) => _loadAlarms()),
      ),
      body: ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<AlarmsViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildLevelFilterChips(viewModel),
                const SizedBox(height: AppConstants.paddingMedium),
                if (_showFilters) _buildFilters(viewModel),
                if (viewModel.isLoading)
                  const LinearProgressIndicator()
                else if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(children: [Text(viewModel.errorMessage!), const SizedBox(height: AppConstants.paddingLarge), ElevatedButton(onPressed: _loadAlarms, child: const Text('Yenile'))]),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadAlarms,
                      child:
                          viewModel.alarms.isEmpty
                              ? const Center(child: Text('Alarm bulunamadı'))
                              : ListView.builder(
                                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                itemCount: viewModel.alarms.length,
                                itemBuilder: (context, index) {
                                  final alarm = viewModel.alarms[index];
                                  return _buildAlarmCard(alarm, context);
                                },
                              ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilters(AlarmsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))],
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppConstants.borderRadiusLarge), topRight: Radius.circular(AppConstants.borderRadiusLarge)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.filter_list, size: 20, color: Colors.white),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Text('Filtreler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPlantId = null;
                        _selectedDeviceSetupId = widget.deviceSetupId;
                        _selectedDate = null;
                        _selectedLevels.clear();
                        _selectedLevels.addAll(['Major', 'Minor', 'Warning']);
                      });
                      _loadAlarms();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Sıfırla'),
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.deviceSetupId == null) ...[
                  // Ana sayfadan geldiğinde tesis ve inverter seçimi
                  _buildFilterSection(
                    'Tesis Seçimi',
                    Icons.business,
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Tesis Seçiniz',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      value: _selectedPlantId,
                      items: [const DropdownMenuItem<int>(value: null, child: Text('Tümü')), ...viewModel.plants.map((plant) => DropdownMenuItem(value: plant.id, child: Text(plant.name)))],
                      onChanged: (value) async {
                        setState(() {
                          _selectedPlantId = value;
                          _selectedDeviceSetupId = null;
                        });
                        await _loadAlarms();
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildFilterSection(
                    'Inverter Seçimi',
                    Icons.ad_units,
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Inverter Seçiniz',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      value: _selectedDeviceSetupId,
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('Tümü')),
                        ...viewModel.devices
                            .where((device) => _selectedPlantId == null || device.parentId == _selectedPlantId)
                            .map((device) => DropdownMenuItem(value: device.id, child: Text(device.name))),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDeviceSetupId = value);
                        _loadAlarms();
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                ] else ...[
                  // Cihaz sayfasından geldiğinde sadece bilgi göster
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Theme.of(context).primaryColor.withOpacity(0.1), Theme.of(context).primaryColor.withOpacity(0.05)]),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(child: Text('Bu cihaza ait alarmlar gösteriliyor', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 14))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                ],
                _buildFilterSection(
                  'Tarih Seçimi',
                  Icons.calendar_today,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                          ),
                          child: TextButton.icon(
                            icon: Icon(Icons.calendar_today, size: 18, color: Theme.of(context).primaryColor),
                            label: Text(
                              _selectedDate == null ? 'Tüm Tarihler' : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                              style: TextStyle(color: _selectedDate == null ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) : Theme.of(context).primaryColor),
                            ),
                            onPressed: () async {
                              final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
                              if (date != null) {
                                setState(() => _selectedDate = date);
                                _loadAlarms();
                              }
                            },
                          ),
                        ),
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(width: AppConstants.paddingSmall),
                        Container(
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                            icon: Icon(Icons.clear, size: 18, color: Colors.red),
                            onPressed: () {
                              setState(() => _selectedDate = null);
                              _loadAlarms();
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        child,
      ],
    );
  }

  Widget _buildLevelFilterChips(AlarmsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: AppConstants.cardShadow,
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: AppConstants.paddingSmall),
              Text('Alarm Seviyeleri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const Spacer(),
              Text('Toplam: ${viewModel.alarms.length}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children:
                _alarmLevels.map((level) {
                  final isSelected = _selectedLevels.contains(level);
                  final levelColor = _getLevelColor(level);
                  final alarmCount = viewModel.alarms.where((alarm) => alarm.level == level).length;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected ? [BoxShadow(color: levelColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2))] : null,
                    ),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: isSelected ? Colors.white : levelColor, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(level, style: TextStyle(color: isSelected ? Colors.white : levelColor, fontWeight: FontWeight.w600, fontSize: 12)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.3) : levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                            child: Text(alarmCount.toString(), style: TextStyle(color: isSelected ? Colors.white : levelColor, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ),
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
                      selectedColor: levelColor,
                      checkmarkColor: Colors.white,
                      backgroundColor: levelColor.withOpacity(0.1),
                      side: BorderSide(color: levelColor.withOpacity(0.3), width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Major':
        return Colors.red;
      case 'Minor':
        return Colors.orange;
      case 'Warning':
        return Colors.amber.shade700; // Daha koyu ve okunaklı
      default:
        return Colors.grey;
    }
  }

  Widget _buildAlarmCard(AlarmDto alarm, BuildContext context) {
    final levelColor = _getLevelColor(alarm.level);
    final isActive = alarm.clearedAt == null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withOpacity(0.95)]),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(color: levelColor.withOpacity(0.1), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, spreadRadius: 0, offset: const Offset(0, 1)),
        ],
        border: Border.all(color: levelColor.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          onTap: () => _showAlarmDetails(alarm.id, context),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Level Indicator
                    Container(width: 4, height: 40, decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: AppConstants.paddingMedium),
                    // Alarm Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alarm.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(12)),
                                child: Text(alarm.level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          Row(
                            children: [
                              Icon(Icons.business, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                              const SizedBox(width: 4),
                              Expanded(child: Text(alarm.plantName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          if (alarm.deviceSetupName != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.ad_units, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    alarm.deviceSetupName!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                // Status and Time Row
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isActive ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isActive ? Icons.warning : Icons.check_circle, size: 12, color: isActive ? Colors.red : Colors.green),
                          const SizedBox(width: 4),
                          Text(isActive ? 'Aktif' : 'Temizlendi', style: TextStyle(color: isActive ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 10)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Time Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                            const SizedBox(width: 4),
                            Text(DateFormat('dd.MM.yyyy').format(alarm.occuredAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Text(
                          DateFormat('HH:mm').format(alarm.occuredAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
                        ),
                        if (alarm.clearedAt != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 10, color: Colors.green),
                              const SizedBox(width: 2),
                              Text(
                                'Temizlenme: ${DateFormat('dd.MM HH:mm').format(alarm.clearedAt!)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
