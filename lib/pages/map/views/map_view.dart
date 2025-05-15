import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../viewmodels/map_viewmodel.dart';
import '../models/pv_string_model.dart';

class MapView extends StatefulWidget {
  final int plantId;

  const MapView({super.key, required this.plantId});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  late final MapViewModel _viewModel;
  final MapController _mapController = MapController();
  double _offsetLat = 0.0, _offsetLng = 0.0;

  final LatLng _initialTopLeft = const LatLng(39.80705421108194, 32.4570747010855);
  final LatLng _initialBottomRight = const LatLng(39.80647399121594, 32.45791153462235);

  @override
  void initState() {
    super.initState();
    _viewModel = MapViewModel(ApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchPVStrings(widget.plantId);
    if (_viewModel.pvStrings.isNotEmpty) {
      _centerMap();
    }
  }

  void _centerMap() {
    final bounds = LatLngBounds.fromPoints([
      LatLng(_initialTopLeft.latitude + _offsetLat, _initialTopLeft.longitude + _offsetLng),
      LatLng(_initialBottomRight.latitude + _offsetLat, _initialBottomRight.longitude + _offsetLng),
    ]);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  void _adjustOffset(double dLat, double dLng) {
    setState(() {
      _offsetLat += dLat;
      _offsetLng += dLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          final polygonPoints = viewModel.getPolygonPoints();
          final polygonColors = viewModel.getPolygonColors();
          final borderColors = viewModel.getBorderColors();
          final stringAssociations = viewModel.getPolygonStringAssociations();

          return Scaffold(
            appBar: AppBar(
              title: const Text('PV String Monitoring'),
              actions: [
                IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 0.5)),
                IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 0.5)),
                IconButton(icon: const Icon(Icons.center_focus_strong), onPressed: _centerMap),
                PopupMenuButton<ColorMode>(
                  onSelected: viewModel.setColorMode,
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem(value: ColorMode.voltage, child: Text('Voltage (V)')),
                        PopupMenuItem(value: ColorMode.current, child: Text('Current (A)')),
                        PopupMenuItem(value: ColorMode.power, child: Text('Power (W)')),
                      ],
                ),
              ],
            ),
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: const LatLng(39.8067, 32.4575), initialZoom: 22, minZoom: 17, maxZoom: 25, onTap: (_, __) => viewModel.selectString(null)),
                  children: [
                    OverlayImageLayer(
                      overlayImages: [
                        OverlayImage(
                          bounds: LatLngBounds.fromPoints([
                            LatLng(_initialTopLeft.latitude + _offsetLat, _initialTopLeft.longitude + _offsetLng),
                            LatLng(_initialBottomRight.latitude + _offsetLat, _initialBottomRight.longitude + _offsetLng),
                          ]),
                          opacity: 0.8,
                          imageProvider: NetworkImage('http://78.187.86.118:8083/UPLOAD/mistav_2.png'),
                        ),
                      ],
                    ),
                    PolygonLayer(
                      polygons: List.generate(polygonPoints.length, (index) {
                        return Polygon(points: polygonPoints[index], color: polygonColors[index], borderColor: borderColors[index], borderStrokeWidth: 2);
                      }),
                    ),
                    MarkerLayer(
                      markers: List.generate(polygonPoints.length, (index) {
                        final center = viewModel.calculateCenter(polygonPoints[index]);
                        final string = stringAssociations[index];
                        return Marker(
                          point: center,
                          width: 30,
                          height: 30,
                          child: GestureDetector(
                            onTap: () => viewModel.selectString(string),
                            child: Container(
                              decoration: BoxDecoration(color: viewModel.getStringColor(string), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: Center(child: Text(string.technicalName.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                if (viewModel.isLoading) const Center(child: CircularProgressIndicator()),

                if (viewModel.errorMessage != null) Positioned(top: 20, left: 20, right: 20, child: _buildErrorCard(viewModel.errorMessage!)),

                if (viewModel.selectedString != null) _buildInfoCard(viewModel.selectedString!),

                Positioned(
                  right: 10,
                  bottom: 140,
                  child: Column(
                    children: [
                      FloatingActionButton(onPressed: () => _adjustOffset(0.00001, 0), mini: true, child: const Icon(Icons.arrow_upward)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(onPressed: () => _adjustOffset(0, -0.00001), mini: true, child: const Icon(Icons.arrow_back)),
                          const SizedBox(width: 8),
                          FloatingActionButton(onPressed: () => _adjustOffset(0, 0.00001), mini: true, child: const Icon(Icons.arrow_forward)),
                        ],
                      ),
                      FloatingActionButton(onPressed: () => _adjustOffset(-0.00001, 0), mini: true, child: const Icon(Icons.arrow_downward)),
                      Text("Top left ${(_initialTopLeft.latitude + _offsetLat, _initialTopLeft.longitude + _offsetLng)}"),
                      Text("bottom right ${(_initialBottomRight.latitude + _offsetLat, _initialBottomRight.longitude + _offsetLng)}"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => _viewModel.errorMessage = null),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(PVStringModel pvString) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(pvString.technicalName, style: Theme.of(context).textTheme.titleLarge), IconButton(icon: const Icon(Icons.close), onPressed: () => _viewModel.selectString(null))],
              ),
              const SizedBox(height: 8),
              Text('Inverter: ${pvString.inverterName}'),
              Text('Panel Type: ${pvString.panelType}'),
              Text('Panel Count: ${pvString.panelCount}'),
              const Divider(),
              Text('Last Production Data', style: Theme.of(context).textTheme.titleMedium),
              Text('Voltage: ${pvString.lastPVV?.toStringAsFixed(2) ?? 'N/A'} V'),
              Text('Current: ${pvString.lastPVA?.toStringAsFixed(2) ?? 'N/A'} A'),
              Text('Power: ${pvString.lastPower.toStringAsFixed(2)} W'),
              if (pvString.maxPower != null) Text('Max Power Today: ${pvString.maxPower?.toStringAsFixed(2)} W'),
            ],
          ),
        ),
      ),
    );
  }
}
