import 'package:flutter/material.dart';
import '../constant/app_constants.dart';

/// Reusable error display widget for consistent error UI across the app
class ErrorDisplayWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorDisplayWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.retryButtonText,
  });

  bool _isEmptyStateMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('kayıt bulunamadı') ||
        m.contains('kayit bulunamadi') ||
        m.contains('veri bulunamadı') ||
        m.contains('veri bulunamadi') ||
        m.contains('uygun kayıt bulunamadı') ||
        m.contains('uygun kayit bulunamadi') ||
        m.contains('no element'); // fallback if any leaks through
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEmptyState = _isEmptyStateMessage(errorMessage);
    final title = isEmptyState ? 'Kayıt Bulunamadı' : 'Bir Hata Oluştu';
    final icon = isEmptyState ? Icons.inbox_outlined : Icons.error_outline_rounded;
    final accentColor = isEmptyState ? colorScheme.primary : colorScheme.error;
    final containerColor =
        isEmptyState ? colorScheme.primaryContainer.withOpacity(0.12) : colorScheme.errorContainer.withOpacity(0.1);
    final cardColor = isEmptyState ? colorScheme.surfaceContainerHighest.withOpacity(0.6) : colorScheme.errorContainer.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon Container
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
                decoration: BoxDecoration(
                  color: containerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: AppConstants.paddingExtraLarge),
              // Error Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              // Error Message Card
              Card(
                elevation: AppConstants.elevationSmall,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: accentColor,
                        size: AppConstants.iconSizeMedium,
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onErrorContainer,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Retry Button (if onRetry is provided)
              if (onRetry != null) ...[
                const SizedBox(height: AppConstants.paddingExtraLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(retryButtonText ?? 'Yenile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: isEmptyState ? colorScheme.onPrimary : colorScheme.onError,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMedium,
                        horizontal: AppConstants.paddingLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                      elevation: AppConstants.elevationSmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

