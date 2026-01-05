// lib/global/widgets/custom_date_picker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DatePickerMode { day, month, year }

class CustomDatePicker {
  static Future<DateTime?> showCustomDatePicker({required BuildContext context, required DateTime initialDate, required DatePickerMode mode, DateTime? firstDate, DateTime? lastDate}) async {
    DateTime? pickedDate;

    switch (mode) {
      case DatePickerMode.day:
        pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime.now(),
          locale: const Locale('tr', 'TR'),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).colorScheme.surface,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
                textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary)),
              ),
              child: Localizations.override(context: context, locale: const Locale('tr', 'TR'), child: child!),
            );
          },
        );
        break;

      case DatePickerMode.month:
        pickedDate = await showMonthPicker(context: context, initialDate: initialDate, firstDate: firstDate ?? DateTime(2000), lastDate: lastDate ?? DateTime.now());
        break;

      case DatePickerMode.year:
        pickedDate = await showYearPicker(context: context, initialDate: initialDate, firstDate: firstDate ?? DateTime(2000), lastDate: lastDate ?? DateTime.now());
        break;
    }

    return pickedDate;
  }
}

// Ay seçici dialog
Future<DateTime?> showMonthPicker({required BuildContext context, required DateTime initialDate, required DateTime firstDate, required DateTime lastDate}) {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Ay Seçin', style: Theme.of(context).textTheme.titleLarge),
        content: SizedBox(width: 300, height: 300, child: MonthPickerDialog(initialDate: initialDate, firstDate: firstDate, lastDate: lastDate)),
      );
    },
  );
}

// Yıl seçici dialog
Future<DateTime?> showYearPicker({required BuildContext context, required DateTime initialDate, required DateTime firstDate, required DateTime lastDate}) {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Yıl Seçin', style: Theme.of(context).textTheme.titleLarge),
        content: SizedBox(
          width: 300,
          height: 400,
          child: YearPicker(
            firstDate: firstDate,
            lastDate: lastDate,
            selectedDate: initialDate,
            onChanged: (DateTime date) {
              Navigator.of(context).pop(date);
            },
          ),
        ),
      );
    },
  );
}

// Ay seçici widget
class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const MonthPickerDialog({super.key, required this.initialDate, required this.firstDate, required this.lastDate});

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late DateTime _selectedDate;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Yıl seçici
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.arrow_back_ios, size: 16), onPressed: _selectedYear > widget.firstDate.year ? () => setState(() => _selectedYear--) : null),
            Text(_selectedYear.toString(), style: Theme.of(context).textTheme.headlineSmall),
            IconButton(icon: Icon(Icons.arrow_forward_ios, size: 16), onPressed: _selectedYear < widget.lastDate.year ? () => setState(() => _selectedYear++) : null),
          ],
        ),
        const SizedBox(height: 16),

        // Aylar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final date = DateTime(_selectedYear, month);
              final isSelectable = date.isAfter(widget.firstDate.subtract(const Duration(days: 1))) && date.isBefore(widget.lastDate.add(const Duration(days: 32)));

              final isSelected = _selectedDate.year == _selectedYear && _selectedDate.month == month;

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextButton(
                  onPressed:
                      isSelectable
                          ? () {
                            setState(() {
                              _selectedDate = DateTime(_selectedYear, month);
                            });
                            Navigator.of(context).pop(_selectedDate);
                          }
                          : null,
                  style: TextButton.styleFrom(
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
                    foregroundColor:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : isSelectable
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                  ),
                  child: Text(DateFormat('MMM', 'tr_TR').format(DateTime(0, month))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
