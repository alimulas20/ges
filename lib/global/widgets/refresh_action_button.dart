import 'package:flutter/material.dart';

class RefreshActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String? tooltip;

  const RefreshActionButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
    );
  }
}
