import 'package:flutter/material.dart';
import '../constant/app_constants.dart';

/// Reusable chart tooltip widget that displays time and value information
class ChartTooltipWidget extends StatelessWidget {
  final String timeLabel;
  final double value;
  final String unit;
  final bool isPrediction;
  final VoidCallback? onClose;
  final List<ChartTooltipItem>? items; // Birden fazla seri için

  const ChartTooltipWidget({
    super.key,
    required this.timeLabel,
    this.value = 0,
    this.unit = '',
    this.isPrediction = false,
    this.onClose,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleItems = items != null && items!.isNotEmpty;
    
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zaman bilgisi
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Birden fazla seri varsa liste göster
                  if (hasMultipleItems) ...[
                    ...items!.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.label}: ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: AppConstants.fontSizeSmall,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item.value.toStringAsFixed(1)} ${item.unit}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: AppConstants.fontSizeSmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ] else ...[
                    // Tek seri için eski görünüm
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPrediction ? Icons.trending_up : Icons.show_chart,
                          size: 14,
                          color: isPrediction
                              ? Colors.orange
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${value.toStringAsFixed(1)} $unit${isPrediction ? " (Tahmin)" : ""}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: AppConstants.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onClose != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tooltip item for multiple series
class ChartTooltipItem {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const ChartTooltipItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}

