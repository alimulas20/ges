// widgets/multi_select_dropdown.dart
import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> options;
  final List<T> selectedValues;
  final Function(List<T>) onChanged;
  final String hint;

  const MultiSelectDropdown({required this.options, required this.selectedValues, required this.onChanged, required this.hint, super.key});

  @override
  _MultiSelectDropdownState<T> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  // Track if the dropdown is open to prevent multiple rapid selections
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: widget.hint, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<T>(
            isExpanded: true,
            value: null,
            hint: Text(widget.selectedValues.isEmpty ? widget.hint : '${widget.selectedValues.length} seçili'),
            items: [
              ...widget.options.map((item) {
                return DropdownMenuItem<T>(value: item.value, child: _buildItem(item));
              }),
            ],
            onChanged: (value) {}, // Empty callback to prevent closing
            onTap: () {
              // Track when dropdown is opened
              _isDropdownOpen = true;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(DropdownMenuItem<T> item) {
    return InkWell(
      onTap: () {
        if (!_isDropdownOpen) return;

        // Close the dropdown
        _isDropdownOpen = false;
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });

        // Process the selection
        final newSelection = List<T>.from(widget.selectedValues);
        if (newSelection.contains(item.value)) {
          newSelection.remove(item.value);
        } else {
          newSelection.add(item.value as T);
        }
        widget.onChanged(newSelection);
      },
      child: Row(
        children: [
          Checkbox(
            value: widget.selectedValues.contains(item.value),
            onChanged: null, // We handle the tap on the entire row
          ),
          Expanded(child: item.child),
        ],
      ),
    );
  }
}
