// plant_update_view.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/utils/snack_bar_utils.dart';
import '../models/plant_dto.dart';
import '../services/plant_service.dart';
import '../viewmodels/plant_update_viewmodel.dart';

class PlantUpdateView extends StatefulWidget {
  final int plantId;

  const PlantUpdateView({super.key, required this.plantId});

  @override
  State<PlantUpdateView> createState() => _PlantUpdateViewState();
}

class _PlantUpdateViewState extends State<PlantUpdateView> {
  late PlantUpdateViewModel _viewModel;
  late PlantDto _editedPlant;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = PlantUpdateViewModel(PlantService());
    _loadPlant();
  }

  Future<void> _loadPlant() async {
    await _viewModel.loadPlant(widget.plantId);
    if (_viewModel.currentPlant != null) {
      setState(() {
        _editedPlant = _viewModel.currentPlant!;
        _isInitialized = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) {
        return;
      }
      try {
        var url = await _viewModel.setPlantPicture(widget.plantId, pickedFile);
        setState(() {
          _editedPlant = _editedPlant.copyWith(plantPicture: url);
        });
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Resim başarıyla yüklendi');
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Resim yüklenemedi: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<PlantUpdateViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && !_isInitialized) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tesis Düzenle', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
                toolbarHeight: AppConstants.appBarHeight,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null && !_isInitialized) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tesis Düzenle', style: TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
                toolbarHeight: AppConstants.appBarHeight,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.error!),
                    const SizedBox(height: AppConstants.paddingExtraLarge),
                    ElevatedButton(
                      onPressed: () => _loadPlant(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!_isInitialized || viewModel.currentPlant == null) {
            return const SizedBox.shrink();
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(_editedPlant.name, style: const TextStyle(fontSize: AppConstants.fontSizeExtraLarge)),
              actions: [
                if (_hasChanges())
                  IconButton(
                    icon: _isSaving
                        ? SizedBox(
                            width: AppConstants.iconSizeMedium,
                            height: AppConstants.iconSizeMedium,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                            ),
                          )
                        : const Icon(Icons.save),
                    onPressed: _isSaving ? null : () => _saveChanges(context),
                  ),
              ],
              toolbarHeight: AppConstants.appBarHeight,
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
              child: ListView(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: AppConstants.imageMediumSize,
                          height: AppConstants.imageMediumSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 2),
                          ),
                          child: ClipOval(
                            child: _editedPlant.plantPicture != null && _editedPlant.plantPicture!.isNotEmpty
                                ? Image.network(
                                    _editedPlant.plantPicture!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: colorScheme.surfaceContainerHighest,
                                        child: Icon(Icons.business, size: AppConstants.iconSizeExtraLarge, color: colorScheme.onSurfaceVariant),
                                      );
                                    },
                                  )
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(Icons.business, size: AppConstants.iconSizeExtraLarge, color: colorScheme.onSurfaceVariant),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: AppConstants.paddingHuge,
                            width: AppConstants.paddingHuge,
                            decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(AppConstants.borderRadiusCircle)),
                            child: IconButton(
                              icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: AppConstants.paddingExtraLarge),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingExtraLarge),
                  TextFormField(
                    initialValue: _editedPlant.name,
                    decoration: const InputDecoration(labelText: 'Tesis Adı'),
                    onChanged: (value) => setState(() {
                      _editedPlant = _editedPlant.copyWith(name: value);
                    }),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.plantType,
                    decoration: const InputDecoration(labelText: 'Tesis Tipi'),
                    onChanged: (value) => setState(() {
                      _editedPlant = _editedPlant.copyWith(plantType: value);
                    }),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.totalStringCapacityKWp.toString(),
                    decoration: const InputDecoration(labelText: 'Toplam Kapasite (kWp)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        setState(() {
                          _editedPlant = _editedPlant.copyWith(totalStringCapacityKWp: doubleValue);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.address,
                    decoration: const InputDecoration(labelText: 'Adres'),
                    maxLines: 3,
                    onChanged: (value) => setState(() {
                      _editedPlant = _editedPlant.copyWith(address: value);
                    }),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.countryOrRegion,
                    decoration: const InputDecoration(labelText: 'Ülke/Bölge'),
                    onChanged: (value) => setState(() {
                      _editedPlant = _editedPlant.copyWith(countryOrRegion: value);
                    }),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.latitude.toString(),
                    decoration: const InputDecoration(labelText: 'Enlem'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        setState(() {
                          _editedPlant = _editedPlant.copyWith(latitude: doubleValue);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.longitude.toString(),
                    decoration: const InputDecoration(labelText: 'Boylam'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        setState(() {
                          _editedPlant = _editedPlant.copyWith(longitude: doubleValue);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    initialValue: _editedPlant.altitude.toString(),
                    decoration: const InputDecoration(labelText: 'Yükseklik'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        setState(() {
                          _editedPlant = _editedPlant.copyWith(altitude: doubleValue);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _editedPlant.gridConnectionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _editedPlant = _editedPlant.copyWith(gridConnectionDate: picked);
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Şebeke Bağlantı Tarihi'),
                      child: Text(_editedPlant.gridConnectionDate.toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _hasChanges() {
    if (!_isInitialized || _viewModel.currentPlant == null) return false;
    final original = _viewModel.currentPlant!;
    return _editedPlant.name != original.name ||
        _editedPlant.plantType != original.plantType ||
        _editedPlant.totalStringCapacityKWp != original.totalStringCapacityKWp ||
        _editedPlant.address != original.address ||
        _editedPlant.countryOrRegion != original.countryOrRegion ||
        _editedPlant.latitude != original.latitude ||
        _editedPlant.longitude != original.longitude ||
        _editedPlant.altitude != original.altitude ||
        _editedPlant.gridConnectionDate != original.gridConnectionDate;
  }

  void _saveChanges(BuildContext context) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updateDto = PlantUpdateDto.fromPlant(_editedPlant);
      await _viewModel.updatePlant(widget.plantId, updateDto);

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Tesis bilgileri başarıyla güncellendi');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Kaydetme hatası: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

