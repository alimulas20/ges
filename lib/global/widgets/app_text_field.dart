import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final double borderRadius;

  const AppTextField({super.key, required this.controller, required this.labelText, this.prefixIcon, this.suffixIcon, this.isPassword = false, this.borderRadius = 8});

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: theme.colorScheme.onSurface.withAlpha(153)) : null,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.onSurface.withAlpha(153)),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : widget.suffixIcon != null
                ? Icon(widget.suffixIcon)
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.borderRadius), borderSide: BorderSide(color: theme.colorScheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.borderRadius), borderSide: BorderSide(color: theme.colorScheme.outline.withAlpha(126))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.borderRadius), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
