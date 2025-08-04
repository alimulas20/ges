import 'package:flutter/material.dart';

class CompactSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final TextStyle? textStyle;

  const CompactSwitch({super.key, required this.title, required this.value, required this.onChanged, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textStyle ?? Theme.of(context).textTheme.bodyMedium),
        Transform.scale(scale: 0.8, child: Switch(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
      ],
    );
  }
}
