import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/map_service.dart';
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
  final LatLng _initialTopLeft = const LatLng(39.808451, 32.453752);
  final LatLng _initialBottomRight = const LatLng(39.805106, 32.461504);

  // final LatLng _initialTopLeft = const LatLng(39.808560, 32.453596);
  // final LatLng _initialBottomRight = const LatLng(39.805100, 32.461398);

  // ToggleButtons(
  //         isSelected: isSelectedTab,
  //         color: MyColors.grey_60,
  //         selectedBorderColor: MyColors.primary,
  //         borderRadius: BorderRadius.circular(30),
  //         children: [
  //           Container(padding: EdgeInsets.symmetric(horizontal: 25), child: Text("BUTTON 1", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
  //           Container(padding: EdgeInsets.symmetric(horizontal: 25), child: Text("BUTTON 2", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
  //           Container(padding: EdgeInsets.symmetric(horizontal: 25), child: Text("BUTTON 3", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
  //         ],
  //         onPressed: (int index) {
  //           isSelectedTab = List.generate(3, (index) => false);
  //           isSelectedTab[index] = true;
  //           setState(() {});
  //         },
  //       ),

  @override
  void initState() {
    super.initState();
    _viewModel = MapViewModel(MapService());
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchPVStrings(widget.plantId);
    if (_viewModel.pvStrings.isNotEmpty) {
      _centerMap();
    }
  }

  void _centerMap() {
    var center = LatLng(39.806783, 32.457461);
    _mapController.move(center, 19.6);
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
                // PopupMenuButton<ColorMode>(
                //   onSelected: viewModel.setColorMode,
                //   itemBuilder:
                //       (context) => const [
                //         PopupMenuItem(value: ColorMode.voltage, child: Text('Gerilim (V)')),
                //         PopupMenuItem(value: ColorMode.current, child: Text('Akım (A)')),
                //         PopupMenuItem(value: ColorMode.power, child: Text('Güç (W)')),
                //       ],
                // ),
              ],
            ),
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(39.806783, 32.457461),
                    initialZoom: 19.6,
                    minZoom: 0,
                    maxZoom: 25,
                    onTap: (_, __) => viewModel.selectString(null),
                    cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds.fromPoints([_initialTopLeft, _initialBottomRight])),
                  ),
                  children: [
                    OverlayImageLayer(
                      overlayImages: [
                        OverlayImage(
                          bounds: LatLngBounds.fromPoints([_initialTopLeft, _initialBottomRight]),
                          opacity: 0.8,
                          imageProvider: NetworkImage('http://78.187.86.118:8083/UPLOAD/mistav_3.jpg'),
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AnimatedToggleSwitch<ColorMode>.size(
                      current: viewModel.colorMode,
                      style: ToggleStyle(
                        // backgroundColor: const Color(0xFF919191),
                        // indicatorColor: const Color(0xFFEC3345),
                        borderColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        indicatorBorderRadius: BorderRadius.zero,
                      ),
                      values: const [ColorMode.voltage, ColorMode.current, ColorMode.power],
                      iconOpacity: 1.0,
                      selectedIconScale: 1.0,
                      indicatorSize: const Size.fromWidth(100),
                      iconAnimationType: AnimationType.onHover,
                      styleAnimationType: AnimationType.onHover,
                      spacing: 2.0,
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
              Text('Panel Tipi: ${pvString.panelType}'),
              Text('Panel Sayısı: ${pvString.panelCount}'),
              const Divider(),
              Text('Son Üretim Bilgileri', style: Theme.of(context).textTheme.titleMedium),
              Text('Gerilim: ${pvString.lastPVV?.toStringAsFixed(2) ?? 'N/A'} V'),
              Text('Akım: ${pvString.lastPVA?.toStringAsFixed(2) ?? 'N/A'} A'),
              Text('Güç: ${pvString.lastPower.toStringAsFixed(2)} W'),
              if (pvString.maxPower != null) Text('Maksimum Güç(Bugün): ${pvString.maxPower?.toStringAsFixed(2)} W'),
            ],
          ),
        ),
      ),
    );
  }
}
