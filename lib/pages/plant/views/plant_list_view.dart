import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/pages/map/views/map_view.dart';

import '../models/plant_with_latest_weather_dto.dart';
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
        appBar: AppBar(title: const Text('Plants'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _viewModel.fetchPlants())]),
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => MapView(plantId: plant.id)));
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plant.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Type: ${plant.plantType}'),
              Text('Capacity: ${plant.totalStringCapacityKWp} kWp'),
              Text('Location: ${plant.address}'),
              const SizedBox(height: 16),
              if (plant.latestWeather != null) ...[
                const Divider(),
                const Text('Latest Weather', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Temperature: ${plant.latestWeather!.temperature}°C'),
                Text('Wind Speed: ${plant.latestWeather!.windSpeed} m/s'),
                Text('Humidity: ${plant.latestWeather!.humidity}%'),
                Text('Conditions: ${plant.latestWeather!.weatherDescription}'),
                Text('Updated: ${_formatDateTime(plant.latestWeather!.measurementTime)}'),
              ],
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
