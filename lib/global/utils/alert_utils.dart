import 'package:flutter/material.dart';

import '../widgets/custom_alert_dialog.dart';

class AlertUtils {
  /// Shows a user-friendly error dialog
  /// Automatically formats error messages to be more readable
  static Future<void> showError(BuildContext context, {String? title, String? message, Object? error, String? confirmText, VoidCallback? onConfirm}) {
    final errorTitle = title ?? 'Hata';
    String errorMessage;

    if (message != null && message.isNotEmpty) {
      errorMessage = message;
    } else if (error != null) {
      errorMessage = formatErrorMessage(error);
    } else {
      errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }

    return CustomAlertDialog.show(context, title: errorTitle, message: errorMessage, type: AlertType.error, confirmText: confirmText, onConfirm: onConfirm);
  }

  /// Shows a warning dialog
  static Future<void> showWarning(BuildContext context, {required String title, required String message, String? confirmText, VoidCallback? onConfirm}) {
    return CustomAlertDialog.show(context, title: title, message: message, type: AlertType.warning, confirmText: confirmText, onConfirm: onConfirm);
  }

  /// Shows an info dialog
  static Future<void> showInfo(BuildContext context, {required String title, required String message, String? confirmText, VoidCallback? onConfirm}) {
    return CustomAlertDialog.show(context, title: title, message: message, type: AlertType.info, confirmText: confirmText, onConfirm: onConfirm);
  }

  /// Shows a success dialog
  static Future<void> showSuccess(BuildContext context, {required String title, required String message, String? confirmText, VoidCallback? onConfirm}) {
    return CustomAlertDialog.show(context, title: title, message: message, type: AlertType.success, confirmText: confirmText, onConfirm: onConfirm);
  }

  /// Formats error messages to be more user-friendly
  /// Can be used in ViewModels to format error messages before displaying
  static String formatErrorMessage(Object error) {
    String errorString = error.toString();

    // Remove common technical prefixes
    errorString = errorString.replaceAll(RegExp(r'^Exception:\s*'), '');
    errorString = errorString.replaceAll(RegExp(r'^Error:\s*'), '');
    errorString = errorString.replaceAll(RegExp(r'^Failed to .*:\s*'), '');

    // Common error message mappings
    if (errorString.contains('SocketException') || errorString.contains('Failed host lookup')) {
      return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
    }

    if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
      return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
    }

    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return 'Bu işlem için yetkiniz bulunmamaktadır.';
    }

    if (errorString.contains('404') || errorString.contains('Not Found')) {
      return 'İstenen kaynak bulunamadı.';
    }

    if (errorString.contains('500') || errorString.contains('Internal Server Error')) {
      return 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
    }

    if (errorString.contains('502') || errorString.contains('Bad Gateway')) {
      return 'Sunucu geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
    }

    if (errorString.contains('503') || errorString.contains('Service Unavailable')) {
      return 'Servis geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
    }

    // If error message is too technical or long, show a generic message
    if (errorString.length > 200 || errorString.contains('at ') || errorString.contains('package:')) {
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }

    // Capitalize first letter
    if (errorString.isNotEmpty) {
      errorString = errorString[0].toUpperCase() + errorString.substring(1);
    }

    return errorString;
  }
}
