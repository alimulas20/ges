import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:solar/pages/plant/models/plant_with_latest_weather_dto.dart';
import '../../../global/constant/app_constants.dart';
import '../services/map_service.dart';
import '../viewmodels/map_viewmodel.dart';
import '../models/pv_string_model.dart';

class MapView extends StatefulWidget {
  final PlantWithLatestWeatherDto plant;

  const MapView({super.key, required this.plant});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  late final MapViewModel _viewModel;
  final MapController _mapController = MapController();

  // Varsayılan değerler
  LatLng? get _initialTopLeft {
    if (widget.plant.mapTopLeftLat != null && widget.plant.mapTopLeftLng != null) {
      return LatLng(widget.plant.mapTopLeftLat!, widget.plant.mapTopLeftLng!);
    }
    return null;
  }

  LatLng? get _initialBottomRight {
    if (widget.plant.mapBottomRightLat != null && widget.plant.mapBottomRightLng != null) {
      return LatLng(widget.plant.mapBottomRightLat!, widget.plant.mapBottomRightLng!);
    }
    return null;
  }

  double get _initialZoom {
    return widget.plant.mapZoomLevel ?? 19.6;
  }

  String? get _mapImageUrl {
    return widget.plant.mapImageUrl;
  }

  @override
  void initState() {
    super.initState();
    _viewModel = MapViewModel(MapService());
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchPVStrings(widget.plant.id);
    if (_viewModel.pvStrings.isNotEmpty) {
      _centerMap();
    }
  }

  void _centerMap() {
    var center = LatLng(widget.plant.latitude, widget.plant.longitude);
    _mapController.move(center, _initialZoom);
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
              title: const Text('PV Isı Haritası', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
              actions: [
                IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 0.5)),
                IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 0.5)),
                IconButton(icon: const Icon(Icons.center_focus_strong), onPressed: _centerMap),
              ],
              toolbarHeight: AppConstants.appBarHeight,
            ),
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(widget.plant.latitude, widget.plant.longitude),
                    initialZoom: _initialZoom,
                    minZoom: 0,
                    maxZoom: 25,
                    onTap: (_, __) => viewModel.selectString(null),
                    cameraConstraint:
                        _initialBottomRight != null && _initialTopLeft != null
                            ? CameraConstraint.contain(bounds: LatLngBounds.fromPoints([_initialTopLeft!, _initialBottomRight!]))
                            : CameraConstraint.unconstrained(),
                  ),
                  children: [
                    // Sadece mapImageUrl null değilse overlay image göster
                    if (_mapImageUrl != null && _initialBottomRight != null && _initialTopLeft != null)
                      OverlayImageLayer(
                        overlayImages: [
                          OverlayImage(bounds: LatLngBounds.fromPoints([_initialTopLeft!, _initialBottomRight!]), opacity: 0.8, imageProvider: NetworkImage(_mapImageUrl!)),
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
                          width: 60,
                          height: 30,
                          child: GestureDetector(
                            onTap: () => viewModel.selectString(string),
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(color: viewModel.getStringColor(string), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: Center(child: Text(string.technicalName.replaceAll("MPPT-", ""), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AnimatedToggleSwitch<ColorMode>.size(
                          current: viewModel.colorMode,
                          style: ToggleStyle(borderColor: Colors.transparent, borderRadius: BorderRadius.circular(10.0), indicatorBorderRadius: BorderRadius.zero),
                          values: const [ColorMode.voltage, ColorMode.current, ColorMode.power],
                          iconOpacity: 1.0,
                          selectedIconScale: 1.0,
                          indicatorSize: const Size.fromWidth(75),
                          iconAnimationType: AnimationType.onHover,
                          styleAnimationType: AnimationType.onHover,
                          spacing: 1.0,
                          customSeparatorBuilder: (context, local, global) {
                            final opacity = ((global.position - local.position).abs() - 0.5).clamp(0.0, 1.0);
                            return VerticalDivider(indent: 10.0, endIndent: 10.0, color: Colors.white38.withValues(alpha: opacity));
                          },
                          customIconBuilder: (context, local, global) {
                            final text = const ['Gerilim (V)', 'Akım (A)', 'Güç (W)'][local.index];
                            return Center(child: Text(text, style: TextStyle(color: Color.lerp(Colors.black, Colors.white, local.animationValue))));
                          },
                          borderWidth: 0.0,
                          onChanged: (i) => setState(() => viewModel.setColorMode(i)),
                        ),
                      ),
                      SizedBox(width: AppConstants.paddingSmall),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AnimatedToggleSwitch<ShowMode>.size(
                          current: viewModel.showMode,
                          style: ToggleStyle(borderColor: Colors.transparent, borderRadius: BorderRadius.circular(10.0), indicatorBorderRadius: BorderRadius.zero),
                          values: const [ShowMode.last, ShowMode.max],
                          iconOpacity: 1.0,
                          selectedIconScale: 1.0,
                          indicatorSize: const Size.fromWidth(75),
                          iconAnimationType: AnimationType.onHover,
                          styleAnimationType: AnimationType.onHover,
                          spacing: 1.0,
                          customSeparatorBuilder: (context, local, global) {
                            final opacity = ((global.position - local.position).abs() - 0.5).clamp(0.0, 1.0);
                            return VerticalDivider(indent: 5.0, endIndent: 5.0, color: Colors.white38.withValues(alpha: opacity));
                          },
                          customIconBuilder: (context, local, global) {
                            final text = const ['Anlık', 'Nominal'][local.index];
                            return Center(child: Text(text, style: TextStyle(color: Color.lerp(Colors.black, Colors.white, local.animationValue))));
                          },
                          borderWidth: 0.0,
                          onChanged: (i) => setState(() => viewModel.setShowMOde(i)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.isLoading) const Center(child: CircularProgressIndicator()),

                if (viewModel.errorMessage != null) Positioned(top: 20, left: 20, right: 20, child: _buildErrorCard(viewModel.errorMessage!)),

                if (viewModel.selectedString != null) _buildInfoCard(viewModel.selectedString!),
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
              Text('Panel: ${pvString.panelType.displayName}'),
              Text('Panel Özellikleri: ${pvString.panelType.specs}'),
              Text('Panel Sayısı: ${pvString.panelCount}'),
              Text('Beklenen Maksimum Voltaj: ${pvString.panelCount * pvString.panelType.voltageAtMaxPower}'),
              Text('Toplam Kapasite: ${(pvString.panelCount * pvString.panelType.maxPower).toStringAsFixed(0)} W'),
              const Divider(),
              Text('Son Üretim', style: Theme.of(context).textTheme.titleMedium),
              Text('Voltaj: ${pvString.lastPVV?.toStringAsFixed(2) ?? 'N/A'} V'),
              Text('Akım: ${pvString.lastPVA?.toStringAsFixed(2) ?? 'N/A'} A'),
              Text('Güç: ${pvString.lastPower?.toStringAsFixed(2) ?? 'N/A'} W'),
              if (pvString.maxPower != null) ...[
                const Divider(),
                Text('Günlük Maksimum Üretim', style: Theme.of(context).textTheme.titleMedium),
                Text('Voltaj: ${pvString.maxPVV?.toStringAsFixed(2)} W'),
                Text('Akım: ${pvString.maxPVA?.toStringAsFixed(2)} W'),
                Text('Güç: ${pvString.maxPower?.toStringAsFixed(2)} W'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
