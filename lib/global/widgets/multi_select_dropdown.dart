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
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Row(
                    children: [
                      Checkbox(
                        value: widget.selectedValues.contains(item.value),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              widget.onChanged([...widget.selectedValues, item.value as T]);
                            } else {
                              widget.onChanged(widget.selectedValues.where((value) => value != item.value).toList());
                            }
                          });
                        },
                      ),
                      Expanded(child: item.child),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {}, // Empty callback to prevent closing
          ),
        ),
      ),
    );
  }
}
