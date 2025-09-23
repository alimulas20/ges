import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../pages/alarm/model/alarm_dto.dart';
import '../constant/app_constants.dart';

class AlarmDetailDialog extends StatelessWidget {
  final AlarmDetailDto alarm;

  const AlarmDetailDialog({super.key, required this.alarm});

  static Future<void> show(BuildContext context, AlarmDetailDto alarm) {
    return showDialog(context: context, builder: (context) => AlarmDetailDialog(alarm: alarm));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withOpacity(0.95)]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_getLevelColor(alarm.level ?? '').withOpacity(0.1), _getLevelColor(alarm.level ?? '').withOpacity(0.05)]),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppConstants.borderRadiusLarge), topRight: Radius.circular(AppConstants.borderRadiusLarge)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _getLevelColor(alarm.level ?? ''), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.warning, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alarm Detayı', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _getLevelColor(alarm.level ?? ''), borderRadius: BorderRadius.circular(12)),
                          child: Text(alarm.level ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), foregroundColor: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard('Genel Bilgiler', Icons.info_outline, [
                      _buildDetailItem('Alarm Kodu', alarm.alarmCode, Icons.tag),
                      _buildDetailItem('Hata Adı', alarm.name ?? '', Icons.error_outline),
                      _buildDescriptionItem('Açıklama', alarm.description, Icons.description),
                      _buildDetailItem('Kaynak', alarm.source, Icons.source),
                    ]),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildDetailCard('Lokasyon Bilgileri', Icons.location_on, [
                      _buildDetailItem('Tesis', alarm.plantName ?? '', Icons.business),
                      if (alarm.deviceSetupName != null) _buildDetailItem('Inverter', alarm.deviceSetupName!, Icons.ad_units),
                    ]),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildDetailCard('Zaman Bilgileri', Icons.access_time, [
                      _buildDetailItem('Oluşma Zamanı', DateFormat('dd.MM.yyyy HH:mm:ss').format(alarm.occuredAt), Icons.schedule),
                      if (alarm.clearedAt != null) _buildDetailItem('Temizlenme Zamanı', DateFormat('dd.MM.yyyy HH:mm:ss').format(alarm.clearedAt!), Icons.check_circle),
                    ]),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(AppConstants.borderRadiusLarge), bottomRight: Radius.circular(AppConstants.borderRadiusLarge)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Kapat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeMedium)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: AppConstants.fontSizeSmall, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: AppConstants.fontSizeMedium, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: AppConstants.fontSizeSmall, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: AppConstants.fontSizeMedium, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'major':
        return Colors.red;
      case 'minor':
        return Colors.orange;
      case 'warning':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}
