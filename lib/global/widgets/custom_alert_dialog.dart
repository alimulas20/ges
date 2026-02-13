import 'package:flutter/material.dart';

enum AlertType { error, warning, info, success }

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const CustomAlertDialog({super.key, required this.title, required this.message, required this.type, this.confirmText, this.onConfirm});

  static Future<void> show(BuildContext context, {required String title, required String message, required AlertType type, String? confirmText, VoidCallback? onConfirm}) {
    return showDialog(context: context, barrierDismissible: false, builder: (context) => CustomAlertDialog(title: title, message: message, type: type, confirmText: confirmText, onConfirm: onConfirm));
  }

  Color _getColor() {
    switch (type) {
      case AlertType.error:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
        return Colors.blue;
      case AlertType.success:
        return Colors.green;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.info:
        return Icons.info_outline;
      case AlertType.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 48, color: color)),
            const SizedBox(height: 20),
            // Title
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            // Message
            Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(confirmText ?? 'Tamam', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

