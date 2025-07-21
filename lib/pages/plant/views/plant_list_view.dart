import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/pages/map/views/map_view.dart';

import '../../../global/widgets/custom_navbar.dart';
import '../../../global/widgets/network_image_with_placeholder.dart';
import '../models/plant_with_latest_weather_dto.dart';
import '../models/weather_code_utils.dart';
import '../services/plant_service.dart';
import '../viewmodels/plant_list_view_model.dart';

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
        appBar: AppBar(title: const Text('Tesisler', style: TextStyle(fontSize: 20)), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchPlants())]),
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
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(viewModel.errorMessage!, textAlign: TextAlign.center)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => viewModel.fetchPlants(), child: const Text('Yenile')),
                  ],
                ),
              );
            }

            if (viewModel.plants.isEmpty) {
              return const Center(child: Text('Tesis bulunamadı'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomNavbar(pages: [MapView(plantId: plant.id), Container(), Container()], icons: const [Icon(Icons.home), Icon(Icons.abc), Icon(Icons.person_4_rounded)]),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant image
              NetworkImageWithPlaceholder(imageUrl: plant.plantPictureUrl, width: 80, height: 80, placeholderType: 'plant'),
              const SizedBox(width: 12),
              // Plant details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(child: Text(plant.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        if (plant.latestWeather != null)
                          Container(
                            constraints: const BoxConstraints(maxWidth: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: WeatherCodeUtils.getWeatherColor(plant.latestWeather!.weatherCode), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(WeatherCodeUtils.getWeatherIcon(plant.latestWeather!.weatherCode), color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(plant.latestWeather?.weatherDescription ?? "", style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Tür: ${plant.plantType}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bolt, size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Günlük Üretim: ${plant.dailyProduction.toStringAsFixed(2)} kWh',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Kapasite: ${plant.totalStringCapacityKWp.toStringAsFixed(2)} kWp', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(plant.address, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
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
