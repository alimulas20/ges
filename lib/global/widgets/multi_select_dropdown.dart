// widgets/multi_select_dropdown.dart
import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<DropdownMenuItem<int>> options;
  final List<int> selectedValues;
  final Function(List<int>) onChanged;
  final String hint;

  const MultiSelectDropdown({required this.options, required this.selectedValues, required this.onChanged, required this.hint, super.key});

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: widget.hint, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<int>(
            isExpanded: true,
            value: null,
            hint: Text(widget.selectedValues.isEmpty ? widget.hint : '${widget.selectedValues.length} seçili'),
            items: [
              ...widget.options.map((item) {
                return DropdownMenuItem<int>(
                  value: item.value,
                  child: Row(
                    children: [
                      Checkbox(
                        value: widget.selectedValues.contains(item.value),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              widget.onChanged([...widget.selectedValues, item.value!]);
                            } else {
                              widget.onChanged(widget.selectedValues.where((id) => id != item.value).toList());
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
