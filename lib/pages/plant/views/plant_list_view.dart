import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar/pages/plant/views/plant_status_view.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/widgets/custom_navbar.dart';
import '../../../global/widgets/network_image_with_placeholder.dart';
import '../../alarm/views/alarm_view.dart';
import '../../device/view/device_setup_list_view.dart';
import '../../map/views/map_view.dart';
import '../models/plant_with_latest_weather_dto.dart';
import '../models/weather_code_utils.dart';
import '../services/plant_service.dart';
import '../viewmodels/plant_list_view_model.dart';
import 'plant_production_view.dart';

class PlantListView extends StatefulWidget {
  const PlantListView({super.key});

  @override
  State<PlantListView> createState() => _PlantListViewState();
}

class _PlantListViewState extends State<PlantListView> {
  late final PlantListViewModel _viewModel;
  String _selectedFilter = 'Tümü'; // Tümü, Normal, Arızalı, Çevrim Dışı

  @override
  void initState() {
    super.initState();
    _viewModel = PlantListViewModel(PlantService());
    _viewModel.fetchPlants();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tesisler', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
          toolbarHeight: AppConstants.appBarHeight,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (String value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem(value: 'Tümü', child: Text('Tümü')),
                    const PopupMenuItem(value: 'Normal', child: Text('Normal')),
                    const PopupMenuItem(value: 'Arızalı', child: Text('Arızalı')),
                    const PopupMenuItem(value: 'Çevrim Dışı', child: Text('Çevrim Dışı')),
                  ],
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchPlants()),
          ],
        ),
        body: Consumer<PlantListViewModel>(
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
                    ElevatedButton(onPressed: () => viewModel.fetchPlants(), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            if (viewModel.plants.isEmpty) {
              return const Center(child: Text('Tesis bulunamadı'));
            }

            final filteredPlants = _getFilteredPlants(viewModel.plants);

            return Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = filteredPlants[index];
                      return _buildPlantCard(plant);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<PlantWithLatestWeatherDto> _getFilteredPlants(List<PlantWithLatestWeatherDto> plants) {
    if (_selectedFilter == 'Tümü') return plants;

    return plants.where((plant) {
      final alarmStatus = _getPlantAlarmStatus(plant);
      return alarmStatus == _selectedFilter;
    }).toList();
  }

  String _getPlantAlarmStatus(PlantWithLatestWeatherDto plant) {
    if (plant.alarms == null || plant.alarms!.isEmpty) {
      return 'Normal';
    }

    final hasSystemAlarm = plant.alarms!.any((alarm) => alarm.source.toLowerCase() == 'system');
    final hasDeviceAlarm = plant.alarms!.any((alarm) => alarm.source.toLowerCase() == 'device');

    if (hasSystemAlarm) {
      return 'Çevrim Dışı';
    } else if (hasDeviceAlarm) {
      return 'Arızalı';
    } else {
      return 'Normal';
    }
  }

  Widget _buildFilterChips() {
    final filters = ['Tümü', 'Normal', 'Arızalı', 'Çevrim Dışı'];
    final counts = _getFilterCounts();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              final count = counts[filter] ?? 0;
              final color = _getFilterColor(filter);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
                  child: Card(
                    elevation: isSelected ? AppConstants.elevationMedium : AppConstants.elevationSmall,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      side: BorderSide(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 2 : 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall, vertical: AppConstants.paddingSmall),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                filter,
                                style: TextStyle(color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: AppConstants.fontSizeSmall),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(count.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeMedium)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Map<String, int> _getFilterCounts() {
    final counts = <String, int>{'Tümü': _viewModel.plants.length, 'Normal': 0, 'Arızalı': 0, 'Çevrim Dışı': 0};

    for (final plant in _viewModel.plants) {
      final status = _getPlantAlarmStatus(plant);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Normal':
        return const Color(0xFF4CAF50); // Yeşil
      case 'Arızalı':
        return const Color(0xFFF44336); // Kırmızı
      case 'Çevrim Dışı':
        return const Color(0xFF9E9E9E); // Gri
      case 'Tümü':
        return const Color(0xFF212121); // Siyah
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Widget _buildPlantCard(PlantWithLatestWeatherDto plant) {
    final alarmStatus = _getPlantAlarmStatus(plant);
    final statusColor = _getFilterColor(alarmStatus);

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
                    pages: [PlantStatusView(plantId: plant.id), MapView(plant: plant), DeviceSetupListView(plantId: plant.id), PlantProductionView(plantId: plant.id)],
                    tabs: const [
                      Tab(icon: Icon(Icons.monitor), text: "Genel Görünüm"),
                      Tab(icon: Icon(Icons.map), text: "Harita"),
                      Tab(icon: Icon(Icons.ad_units_outlined), text: "Cihazlar"),
                      Tab(icon: Icon(Icons.show_chart), text: "İstatistik"),
                    ],
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Plant image
              NetworkImageWithPlaceholder(imageUrl: plant.plantPictureUrl, width: AppConstants.imageThumbnailSize, height: AppConstants.imageThumbnailSize, placeholderType: 'plant'),
              const SizedBox(width: AppConstants.paddingLarge),
              // Plant details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            plant.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: statusColor),
                            maxLines: AppConstants.maxLinesMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            _buildAlarmStatusChip(alarmStatus, statusColor),
                            const SizedBox(width: 8),
                            if (plant.latestWeather != null)
                              Container(
                                constraints: const BoxConstraints(maxWidth: AppConstants.imageMediumSize),
                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                                decoration: BoxDecoration(
                                  color: WeatherCodeUtils.getWeatherColor(plant.latestWeather!.weatherCode),
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(WeatherCodeUtils.getWeatherIcon(plant.latestWeather!.weatherCode), color: Colors.white, size: AppConstants.iconSizeSmall),
                                    const SizedBox(width: AppConstants.paddingSmall),
                                    Flexible(
                                      child: Text(
                                        plant.latestWeather?.weatherDescription ?? "",
                                        style: const TextStyle(color: Colors.white, fontSize: AppConstants.fontSizeSmall),
                                        maxLines: AppConstants.maxLinesSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text('Tür: ${plant.plantType}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Row(
                      children: [
                        Icon(Icons.bolt, size: AppConstants.iconSizeSmall, color: Theme.of(context).primaryColor),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Günlük Üretim: ${plant.dailyProduction.toStringAsFixed(AppConstants.decimalPlaces)} kWh',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text('Kapasite: ${plant.totalStringCapacityKWp.toStringAsFixed(AppConstants.decimalPlaces)} kWp', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(plant.address, style: Theme.of(context).textTheme.bodySmall, maxLines: AppConstants.maxLinesSmall, overflow: TextOverflow.ellipsis),
                    if (plant.alarms != null && plant.alarms!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingSmall),
                      GestureDetector(
                        onTap: () => _showAlarmDetails(plant),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 16, color: statusColor),
                              const SizedBox(width: 4),
                              Text('${plant.alarms!.length} Alarm - Detayları Gör', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _showAlarmDetails(PlantWithLatestWeatherDto plant) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AlarmsPage(plantId: plant.id)));
  }
}
