import 'package:flutter/material.dart';

import '../../../global/constant/app_constants.dart';
import '../../../global/dtos/dropdown_dto.dart';

class PlantSelectionDialog extends StatefulWidget {
  final List<DropdownDto> availablePlants;
  final String title;

  const PlantSelectionDialog({super.key, required this.availablePlants, this.title = 'Tesis Seç'});

  @override
  State<PlantSelectionDialog> createState() => _PlantSelectionDialogState();

  static Future<List<int>?> show(BuildContext context, {required List<DropdownDto> availablePlants, String title = 'Tesis Seç'}) {
    return showDialog<List<int>>(context: context, builder: (context) => PlantSelectionDialog(availablePlants: availablePlants, title: title));
  }
}

class _PlantSelectionDialogState extends State<PlantSelectionDialog> {
  final Set<int> _selectedPlants = <int>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(children: [Icon(Icons.business, color: colorScheme.primary), const SizedBox(width: AppConstants.paddingSmall), Text(widget.title)]),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                widget.availablePlants.map((plant) {
                  final isSelected = _selectedPlants.contains(plant.id);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingExtraSmall),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      border: Border.all(color: isSelected ? colorScheme.primary.withOpacity(0.5) : colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: CheckboxListTile(
                      title: Text(plant.name, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedPlants.add(plant.id);
                          } else {
                            _selectedPlants.remove(plant.id);
                          }
                        });
                      },
                      activeColor: colorScheme.primary,
                      checkColor: colorScheme.onPrimary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant), child: const Text('İptal')),
        ElevatedButton(
          onPressed: _selectedPlants.isEmpty ? null : () => Navigator.pop(context, _selectedPlants.toList()),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
          ),
          child: Text('Ekle (${_selectedPlants.length})'),
        ),
      ],
    );
  }
}
