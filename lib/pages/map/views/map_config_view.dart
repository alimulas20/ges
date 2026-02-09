import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:solar/pages/plant/models/plant_with_latest_weather_dto.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/utils/snack_bar_utils.dart';
import '../../plant/services/plant_service.dart';
import '../models/pv_string_model.dart';
import '../services/map_service.dart';
import '../viewmodels/map_config_viewmodel.dart';

class MapConfigView extends StatefulWidget {
  final PlantWithLatestWeatherDto plant;

  const MapConfigView({super.key, required this.plant});

  @override
  MapConfigViewState createState() => MapConfigViewState();
}

class MapConfigViewState extends State<MapConfigView> {
  late final MapConfigViewModel _viewModel;
  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationSeriesNameController = TextEditingController();
  double _currentZoom = 19.6;

  // Güncel plant bilgileri (backend'den yüklenen)
  PlantWithLatestWeatherDto? _currentPlant;

  // Varsayılan değerler (güncel plant varsa ondan, yoksa widget.plant'tan)
  LatLng? get _initialTopLeft {
    final plant = _currentPlant ?? widget.plant;
    if (plant.mapTopLeftLat != null && plant.mapTopLeftLng != null) {
      return LatLng(plant.mapTopLeftLat!, plant.mapTopLeftLng!);
    }
    return null;
  }

  LatLng? get _initialBottomRight {
    final plant = _currentPlant ?? widget.plant;
    if (plant.mapBottomRightLat != null && plant.mapBottomRightLng != null) {
      return LatLng(plant.mapBottomRightLat!, plant.mapBottomRightLng!);
    }
    return null;
  }

  double get _initialZoom {
    final plant = _currentPlant ?? widget.plant;
    return plant.mapZoomLevel ?? 19.6;
  }

  String? get _mapImageUrl {
    final plant = _currentPlant ?? widget.plant;
    return plant.mapImageUrl;
  }

  @override
  void initState() {
    super.initState();
    _viewModel = MapConfigViewModel(MapService(), PlantService());
    _currentZoom = _initialZoom;
    _loadData();
  }

  @override
  void dispose() {
    _locationSeriesNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Plant bilgilerini backend'den yeniden yükle (güncel koordinatlar için)
    try {
      final plantService = PlantService();
      final plants = await plantService.getPlantswithWeather();
      final updatedPlant = plants.firstWhere((p) => p.id == widget.plant.id, orElse: () => widget.plant);

      setState(() {
        _currentPlant = updatedPlant;
      });

      // Güncel koordinatları ViewModel'e yükle
      if (updatedPlant.mapTopLeftLat != null && updatedPlant.mapTopLeftLng != null) {
        final topLeft = LatLng(updatedPlant.mapTopLeftLat!, updatedPlant.mapTopLeftLng!);
        final bottomRight = updatedPlant.mapBottomRightLat != null && updatedPlant.mapBottomRightLng != null ? LatLng(updatedPlant.mapBottomRightLat!, updatedPlant.mapBottomRightLng!) : null;
        final zoom = updatedPlant.mapZoomLevel ?? _initialZoom;
        _viewModel.updateMapBounds(topLeft, bottomRight, zoom);
      } else if (_initialTopLeft != null) {
        // Eğer backend'de koordinat yoksa widget.plant'tan yükle
        _viewModel.updateMapBounds(_initialTopLeft, _initialBottomRight, _initialZoom);
      }
    } catch (e) {
      debugPrint('Plant bilgileri yüklenemedi, widget.plant kullanılıyor: $e');
      // Hata durumunda widget.plant'tan yükle
      if (_initialTopLeft != null) {
        _viewModel.updateMapBounds(_initialTopLeft, _initialBottomRight, _initialZoom);
      }
    }

    await _viewModel.loadPVStringsWithGeneration(widget.plant.id);
    _centerMap();
  }

  Future<void> _refreshData({bool updateCoordinates = true}) async {
    await _loadData();
    // Koordinatları widget.plant'tan güncelle (eğer değiştiyse ve updateCoordinates true ise)
    // saveImageAdjustments sonrası koordinatlar zaten ViewModel'de güncellendi, tekrar yüklemeye gerek yok
    if (updateCoordinates && _initialTopLeft != null) {
      _viewModel.updateMapBounds(_initialTopLeft, _initialBottomRight, _initialZoom);
    }
    if (mounted) {
      SnackBarUtils.showSuccess(context, 'Veriler yenilendi');
    }
  }

  void _centerMap() {
    var center = LatLng(widget.plant.latitude, widget.plant.longitude);
    _mapController.move(center, _initialZoom);
  }

  LatLngBounds _getAdjustedImageBounds() {
    // ViewModel'deki güncel koordinatları kullan (offset'ler zaten uygulanmış)
    final topLeft = _viewModel.currentTopLeft ?? _initialTopLeft;
    final bottomRight = _viewModel.currentBottomRight ?? _initialBottomRight;

    if (topLeft == null || bottomRight == null) {
      return LatLngBounds.fromPoints([_initialTopLeft!, _initialBottomRight!]);
    }

    return LatLngBounds.fromPoints([topLeft, bottomRight]);
  }

  Future<void> _pickMapImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Dialog göster - koordinatları düzenle
      final result = await _showMapImageUploadDialog();
      if (result != null && mounted) {
        try {
          await _viewModel.uploadMapPicture(widget.plant.id, pickedFile, result['topLeftLat'], result['topLeftLng'], result['bottomRightLat'], result['bottomRightLng'], result['zoomLevel']);
          if (mounted) {
            SnackBarUtils.showSuccess(context, 'Harita fotoğrafı başarıyla yüklendi');
          }
        } catch (e) {
          if (mounted) {
            SnackBarUtils.showError(context, 'Harita fotoğrafı yüklenemedi: $e');
          }
        }
      }
    }
  }

  Future<Map<String, double?>?> _showMapImageUploadDialog() async {
    final topLeftLatController = TextEditingController(text: widget.plant.mapTopLeftLat?.toString() ?? '');
    final topLeftLngController = TextEditingController(text: widget.plant.mapTopLeftLng?.toString() ?? '');
    final bottomRightLatController = TextEditingController(text: widget.plant.mapBottomRightLat?.toString() ?? '');
    final bottomRightLngController = TextEditingController(text: widget.plant.mapBottomRightLng?.toString() ?? '');
    final zoomController = TextEditingController(text: (widget.plant.mapZoomLevel ?? _currentZoom).toString());

    return showDialog<Map<String, double?>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Harita Görseli Koordinatları'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sol Üst Köşe:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: topLeftLatController,
                          decoration: const InputDecoration(labelText: 'Enlem (Latitude)', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: topLeftLngController,
                          decoration: const InputDecoration(labelText: 'Boylam (Longitude)', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Sağ Alt Köşe:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bottomRightLatController,
                          decoration: const InputDecoration(labelText: 'Enlem (Latitude)', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: bottomRightLngController,
                          decoration: const InputDecoration(labelText: 'Boylam (Longitude)', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: zoomController,
                    decoration: const InputDecoration(labelText: 'Zoom Seviyesi', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'topLeftLat': double.tryParse(topLeftLatController.text),
                    'topLeftLng': double.tryParse(topLeftLngController.text),
                    'bottomRightLat': double.tryParse(bottomRightLatController.text),
                    'bottomRightLng': double.tryParse(bottomRightLngController.text),
                    'zoomLevel': double.tryParse(zoomController.text),
                  });
                },
                child: const Text('Yükle'),
              ),
            ],
          ),
    );
  }

  Future<void> _requestPVGenerationRead() async {
    try {
      await _viewModel.requestPVGenerationRead(widget.plant.id);
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Okuma isteği başarıyla gönderildi');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Okuma isteği gönderilemedi: $e');
      }
    }
  }

  Future<void> _saveLocationSeries() async {
    if (_locationSeriesNameController.text.trim().isEmpty) {
      SnackBarUtils.showError(context, 'Lütfen bir isim girin');
      return;
    }

    try {
      await _viewModel.saveLocationSeries(_locationSeriesNameController.text.trim());
      _locationSeriesNameController.clear();
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Location series başarıyla kaydedildi');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Location series kaydedilemedi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<MapConfigViewModel>(
        builder: (context, viewModel, _) {
          final existingPolygonPoints = viewModel.getExistingPolygonPoints();
          final polygonStringAssociations = viewModel.getPolygonStringAssociations();
          final polygonColors = viewModel.getPolygonColors();
          final borderColors = viewModel.getBorderColors();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Harita Konfigürasyonu', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), tooltip: 'Yenile', onPressed: viewModel.isLoading ? null : _refreshData),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () {
                    final newZoom = _mapController.camera.zoom + 0.1;
                    _mapController.move(_mapController.camera.center, newZoom);
                    setState(() {
                      _currentZoom = newZoom;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () {
                    final newZoom = _mapController.camera.zoom - 0.1;
                    _mapController.move(_mapController.camera.center, newZoom);
                    setState(() {
                      _currentZoom = newZoom;
                    });
                  },
                ),
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
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                    onTap: (tapPosition, point) {
                      if (viewModel.isDrawingMode) {
                        viewModel.addPointToPolygon(point);
                      } else {
                        // Marker dışına tıklanınca seçimi temizle
                        viewModel.selectLocationSeries(null);
                      }
                    },
                    onPositionChanged: (position, hasGesture) {
                      final newZoom = _mapController.camera.zoom;
                      if (_currentZoom != newZoom) {
                        setState(() {
                          _currentZoom = newZoom;
                        });
                      }
                    },
                    // Camera constraint kaldırıldı - görsel kaydırma sırasında sorun çıkmasın diye
                    cameraConstraint: CameraConstraint.unconstrained(),
                  ),
                  children: [
                    // Harita fotoğrafı overlay
                    if (_mapImageUrl != null && _initialBottomRight != null && _initialTopLeft != null)
                      OverlayImageLayer(overlayImages: [OverlayImage(bounds: _getAdjustedImageBounds(), opacity: 0.8, imageProvider: NetworkImage(_mapImageUrl!))]),
                    // Mevcut polygon'lar (renklendirilmiş)
                    PolygonLayer(
                      polygons: [
                        ...List.generate(existingPolygonPoints.length, (index) {
                          return Polygon(
                            points: existingPolygonPoints[index],
                            color: index < polygonColors.length ? polygonColors[index] : Colors.grey.withAlpha(100),
                            borderColor: index < borderColors.length ? borderColors[index] : Colors.grey,
                            borderStrokeWidth: 2,
                          );
                        }),
                        // Çizilmekte olan polygon
                        if (viewModel.currentPolygonPoints.length >= 2)
                          Polygon(points: viewModel.currentPolygonPoints, color: Colors.blue.withAlpha(100), borderColor: Colors.blue, borderStrokeWidth: 3),
                      ],
                    ),
                    // MarkerLayer - mevcut polygon'ların merkezlerini göster
                    if (_currentZoom > 19.5)
                      MarkerLayer(
                        markers: List.generate(existingPolygonPoints.length, (index) {
                          final center = viewModel.calculateCenter(existingPolygonPoints[index]);
                          final string = index < polygonStringAssociations.length ? polygonStringAssociations[index] : null;
                          if (string == null) {
                            return Marker(point: center, width: 0, height: 0, child: const SizedBox.shrink());
                          }
                          // Location series bilgisini al
                          final locationSeriesInfo = viewModel.getLocationSeriesByIndex(index);
                          return Marker(
                            point: center,
                            width: 60,
                            height: 30,
                            child: GestureDetector(
                              onTap: () {
                                if (locationSeriesInfo.series != null && locationSeriesInfo.pvString != null) {
                                  viewModel.selectLocationSeries((series: locationSeriesInfo.series!, pvString: locationSeriesInfo.pvString!));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(color: viewModel.getStringColor(string), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: Center(child: Text(string.technicalName.replaceAll("MPPT-", ""), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
                // Renklendirme kontrolleri
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
                          onChanged: (i) => setState(() => viewModel.setShowMode(i)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Map Edit Mode kontrolleri
                if (viewModel.isMapEditMode && _mapImageUrl != null)
                  Positioned(
                    top: 60,
                    left: 8,
                    right: 8,
                    child: Card(
                      color: Colors.red.withAlpha(200),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune, color: Colors.white),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('Görsel Düzenleme Modu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                IconButton(
                                  icon: const Icon(Icons.save, color: Colors.white),
                                  onPressed:
                                      viewModel.isSaving
                                          ? null
                                          : () async {
                                            try {
                                              await viewModel.saveImageAdjustments(widget.plant.id);
                                              if (mounted) {
                                                SnackBarUtils.showSuccess(context, 'Koordinatlar kaydedildi');
                                                // Koordinatları ViewModel'den güncelle (zaten kaydedildi)
                                                // Refresh yapmaya gerek yok çünkü koordinatlar ViewModel'de güncellendi
                                                // Sadece offset'ler sıfırlandı, koordinatlar güncel
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                SnackBarUtils.showError(context, 'Koordinatlar kaydedilemedi: $e');
                                              }
                                            }
                                          },
                                  tooltip: 'Kaydet',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  onPressed: () {
                                    viewModel.resetImageAdjustments();
                                    // Başlangıç koordinatlarına dön
                                    if (_initialTopLeft != null) {
                                      viewModel.updateMapBounds(_initialTopLeft, _initialBottomRight, _initialZoom);
                                    }
                                  },
                                  tooltip: 'Sıfırla',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Yukarı/Aşağı', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_upward, color: Colors.white),
                                            onPressed: () => viewModel.adjustImageOffset(1, 0),
                                            tooltip: 'Görseli Aşağı Kaydır (Polygon\'lar Yukarı)',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_downward, color: Colors.white),
                                            onPressed: () => viewModel.adjustImageOffset(-1, 0),
                                            tooltip: 'Görseli Yukarı Kaydır (Polygon\'lar Aşağı)',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Sol/Sağ', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                                            onPressed: () => viewModel.adjustImageOffset(0, -1),
                                            tooltip: 'Görseli Sağa Kaydır (Polygon\'lar Sola)',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                            onPressed: () => viewModel.adjustImageOffset(0, 1),
                                            tooltip: 'Görseli Sola Kaydır (Polygon\'lar Sağa)',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Zoom: ', style: TextStyle(color: Colors.white, fontSize: 12)),
                                Text(viewModel.currentZoom.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                                  onPressed: () {
                                    viewModel.adjustZoomLevel(
                                      -0.1,
                                      onZoomChanged: (newZoom) {
                                        // Harita zoom'unu güncelle
                                        _mapController.move(_mapController.camera.center, newZoom);
                                        setState(() {
                                          _currentZoom = newZoom;
                                        });
                                      },
                                    );
                                  },
                                  tooltip: 'Zoom Azalt',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                                  onPressed: () {
                                    viewModel.adjustZoomLevel(
                                      0.1,
                                      onZoomChanged: (newZoom) {
                                        // Harita zoom'unu güncelle
                                        _mapController.move(_mapController.camera.center, newZoom);
                                        setState(() {
                                          _currentZoom = newZoom;
                                        });
                                      },
                                    );
                                  },
                                  tooltip: 'Zoom Artır',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Çizim modu göstergesi
                if (viewModel.isDrawingMode)
                  Positioned(
                    top: viewModel.isMapEditMode && _mapImageUrl != null ? 200 : 60,
                    left: 8,
                    right: 8,
                    child: Card(
                      color: Colors.blue.withAlpha(200),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Çizim Modu Aktif - Haritaya tıklayarak polygon çizin (${viewModel.currentPolygonPoints.length} nokta)',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Loading indicator
                if (viewModel.isLoading || viewModel.isSaving) const Center(child: CircularProgressIndicator()),
                // Error message
                if (viewModel.errorMessage != null)
                  Positioned(
                    top: viewModel.isDrawingMode ? 60 : 20,
                    left: 20,
                    right: 20,
                    child: Card(
                      color: Colors.red[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(child: Text(viewModel.errorMessage!)),
                            IconButton(icon: const Icon(Icons.close), onPressed: () => viewModel.errorMessage = null),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Çizim modu alt paneli
                if (viewModel.isDrawingMode)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Card(
                      elevation: 8,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // PV String seçici (gruplu - Inverter bazlı)
                            DropdownButtonFormField<PVStringModel>(
                              value: viewModel.selectedPVString,
                              decoration: const InputDecoration(labelText: 'PV String Seçin', border: OutlineInputBorder()),
                              items: _buildGroupedPVStringItems(viewModel),
                              onChanged: (pvString) {
                                viewModel.setSelectedPVString(pvString);
                              },
                            ),
                            const SizedBox(height: 12),
                            // Polygon ismi
                            TextField(
                              controller: _locationSeriesNameController,
                              decoration: const InputDecoration(labelText: 'Polygon İsmi', border: OutlineInputBorder(), hintText: 'Örn: Panel Grubu 1'),
                            ),
                            const SizedBox(height: 12),
                            // Butonlar
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Temizle'),
                                    onPressed: () {
                                      viewModel.clearCurrentPolygon();
                                      _locationSeriesNameController.clear();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.save),
                                    label: const Text('Kaydet'),
                                    onPressed: viewModel.selectedPVString != null && viewModel.currentPolygonPoints.length >= 3 && !viewModel.isSaving ? _saveLocationSeries : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Location Series bilgi kartı
                if (viewModel.selectedLocationSeries != null) _buildLocationSeriesInfoCard(viewModel),
              ],
            ),
            floatingActionButton: _buildFloatingActionButtons(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons(MapConfigViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map Edit Mode toggle (sadece görsel varsa görünür) - Kaydırma için
        if (_mapImageUrl != null)
          FloatingActionButton(
            heroTag: 'map_edit_mode',
            onPressed: () {
              viewModel.toggleMapEditMode();
            },
            backgroundColor: viewModel.isMapEditMode ? Colors.red : Colors.grey[600],
            tooltip: 'Harita Kaydırma',
            child: Icon(viewModel.isMapEditMode ? Icons.tune : Icons.tune_outlined),
          ),
        if (_mapImageUrl != null) const SizedBox(height: 8),
        // Çizim modu toggle
        FloatingActionButton(
          heroTag: 'drawing_mode',
          onPressed: () {
            viewModel.toggleDrawingMode();
            if (!viewModel.isDrawingMode) {
              _locationSeriesNameController.clear();
            }
          },
          backgroundColor: viewModel.isDrawingMode ? Colors.blue : Colors.grey,
          tooltip: 'Polygon Çizimi',
          child: Icon(viewModel.isDrawingMode ? Icons.edit_off : Icons.edit),
        ),
        const SizedBox(height: 8),
        // Okuma isteği
        FloatingActionButton(
          heroTag: 'read_request',
          onPressed: viewModel.isSaving ? null : _requestPVGenerationRead,
          backgroundColor: Colors.green,
          tooltip: 'Okuma İsteği Gönder',
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        // Fotoğraf yükle
        FloatingActionButton(
          heroTag: 'upload_image',
          onPressed: viewModel.isSaving ? null : _pickMapImage,
          backgroundColor: Colors.purple,
          tooltip: 'Harita Görseli Yükle',
          child: const Icon(Icons.photo_library),
        ),
      ],
    );
  }

  List<DropdownMenuItem<PVStringModel>> _buildGroupedPVStringItems(MapConfigViewModel viewModel) {
    final items = <DropdownMenuItem<PVStringModel>>[];
    final grouped = viewModel.pvStringsByInverter;
    final inverterNames = grouped.keys.toList()..sort();

    for (var inverterName in inverterNames) {
      final pvStrings = grouped[inverterName]!;

      // Inverter başlığı (disabled, sadece görünür)
      items.add(
        DropdownMenuItem<PVStringModel>(
          enabled: false,
          value: null,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(inverterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
        ),
      );

      // Bu inverter'a ait PV String'ler
      for (var pvString in pvStrings) {
        items.add(
          DropdownMenuItem<PVStringModel>(
            value: pvString,
            child: Padding(padding: const EdgeInsets.only(left: 16.0), child: Text('${pvString.technicalName} (${pvString.locationSeries.length} polygon)')),
          ),
        );
      }
    }

    return items;
  }

  Widget _buildLocationSeriesInfoCard(MapConfigViewModel viewModel) {
    final selected = viewModel.selectedLocationSeries;
    if (selected == null) return const SizedBox.shrink();

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected.series.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('PV String: ${selected.pvString.technicalName}', style: Theme.of(context).textTheme.bodyMedium),
                        Text('Inverter: ${selected.pvString.inverterName}', style: Theme.of(context).textTheme.bodySmall),
                        Text('Nokta Sayısı: ${selected.series.points.length}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => viewModel.selectLocationSeries(null)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Düzenle'),
                      onPressed: () => _showUpdateLocationSeriesDialog(context, viewModel, selected.series, selected.pvString),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Sil'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _showDeleteLocationSeriesDialog(context, viewModel, selected.series),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateLocationSeriesDialog(BuildContext context, MapConfigViewModel viewModel, LocationSeries series, PVStringModel pvString) async {
    final nameController = TextEditingController(text: series.name);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Series Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'İsim', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                Text('Not: Polygon noktalarını değiştirmek için yeni bir polygon çizin ve bu location series\'i silin.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    SnackBarUtils.showError(context, 'Lütfen bir isim girin');
                    return;
                  }

                  Navigator.pop(context);

                  try {
                    final points = series.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
                    await viewModel.updateLocationSeries(series.id, nameController.text.trim(), points);
                    viewModel.selectLocationSeries(null);
                    if (mounted) {
                      SnackBarUtils.showSuccess(context, 'Location series güncellendi');
                    }
                  } catch (e) {
                    if (mounted) {
                      SnackBarUtils.showError(context, 'Location series güncellenemedi: $e');
                    }
                  }
                },
                child: const Text('Güncelle'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteLocationSeriesDialog(BuildContext context, MapConfigViewModel viewModel, LocationSeries series) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Silme Onayı'),
            content: Text('${series.name} location series\'ini silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      try {
        await viewModel.deleteLocationSeries(series.id);
        viewModel.selectLocationSeries(null);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Location series silindi');
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Location series silinemedi: $e');
        }
      }
    }
  }
}
