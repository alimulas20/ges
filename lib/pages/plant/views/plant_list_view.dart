import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/widgets/custom_navbar.dart';
import '../../../global/widgets/network_image_with_placeholder.dart';
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
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchPlants())],
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

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: viewModel.plants.length,
              itemBuilder: (context, index) {
                final plant = viewModel.plants[index];
                return _buildPlantCard(plant);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlantCard(PlantWithLatestWeatherDto plant) {
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
                    pages: [MapView(plantId: plant.id), DeviceSetupListView(plantId: plant.id), PlantProductionView(plantId: plant.id)],
                    icons: const [Icon(Icons.home), Icon(Icons.devices), Icon(Icons.person_4_rounded)],
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: AppConstants.maxLinesMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (plant.latestWeather != null)
                          Container(
                            constraints: const BoxConstraints(maxWidth: AppConstants.imageMediumSize),
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                            decoration: BoxDecoration(color: WeatherCodeUtils.getWeatherColor(plant.latestWeather!.weatherCode), borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
