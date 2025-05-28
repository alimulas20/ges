import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/pages/map/views/map_view.dart';

import '../../../global/widgets/custom_navbar.dart';
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
        appBar: AppBar(title: const Text('Tesisler'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchPlants())]),
        body: Consumer<PlantListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(viewModel.errorMessage!), const SizedBox(height: 16), ElevatedButton(onPressed: () => viewModel.fetchPlants(), child: const Text('Retry'))],
                ),
              );
            }

            if (viewModel.plants.isEmpty) {
              return const Center(child: Text('No plants found'));
            }

            return ListView.builder(
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomNavbar(pages: [MapView(plantId: plant.id), Container(), Container()], icons: [Icon(Icons.home), Icon(Icons.abc), Icon(Icons.person_4_rounded)])),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plant.name, style: Theme.of(context).textTheme.titleLarge),
                  if (plant.latestWeather != null)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: WeatherCodeUtils.getWeatherColor(plant.latestWeather!.weatherCode), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(WeatherCodeUtils.getWeatherIcon(plant.latestWeather!.weatherCode), color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(plant.latestWeather?.weatherDescription ?? "", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Type: ${plant.plantType}'),
              Text('Capacity: ${plant.totalStringCapacityKWp} kWp'),
              Text('Location: ${plant.address}'),
              //const SizedBox(height: 16),
              // if (plant.latestWeather != null) ...[
              //   const Divider(),
              //   const Text('Latest Weather', style: TextStyle(fontWeight: FontWeight.bold)),
              //   const SizedBox(height: 8),
              //   Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text('Temperature: ${plant.latestWeather!.temperature}°C'),
              //             Text('Wind Speed: ${plant.latestWeather!.windSpeed} m/s'),
              //             Text('Humidity: ${plant.latestWeather!.humidity}%'),
              //           ],
              //         ),
              //       ),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text('Cloud Cover: ${plant.latestWeather!.cloudCover}%'),
              //             Text('Code: ${plant.latestWeather!.weatherCode}'),
              //             Text('Updated: ${_formatDateTime(plant.latestWeather!.measurementTime)}'),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  // String _formatDateTime(DateTime dateTime) {
  //   return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  // }
}
