// widgets/multi_select_dropdown.dart
import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> options;
  final List<T> selectedValues;
  final Function(List<T>) onChanged;
  final String hint;

  const MultiSelectDropdown({
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.hint,
    super.key,
  });

  @override
  MultiSelectDropdownState<T> createState() => MultiSelectDropdownState<T>();
}

class MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final List<T> _tempSelectedValues = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedValues.addAll(widget.selectedValues);
  }

  @override
  void didUpdateWidget(MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValues != widget.selectedValues) {
      _tempSelectedValues.clear();
      _tempSelectedValues.addAll(widget.selectedValues);
    }
  }

  void _showMultiSelectDialog() {
    setState(() {
      _tempSelectedValues.clear();
      _tempSelectedValues.addAll(widget.selectedValues);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(widget.hint),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final item = widget.options[index];
                    final isSelected = _tempSelectedValues.contains(item.value);
                    return CheckboxListTile(
                      title: item.child,
                      value: isSelected,
                      onChanged: (bool? checked) {
                        setDialogState(() {
                          if (checked == true) {
                            if (!_tempSelectedValues.contains(item.value)) {
                              _tempSelectedValues.add(item.value!);
                            }
                          } else {
                            _tempSelectedValues.remove(item.value);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onChanged(List<T>.from(_tempSelectedValues));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Göster'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showMultiSelectDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.hint,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          widget.selectedValues.isEmpty
              ? widget.hint
              : '${widget.selectedValues.length} seçili',
          style: TextStyle(
            color: widget.selectedValues.isEmpty
                ? Colors.grey
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
