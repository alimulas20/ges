extension DateTimeDirectExtension on DateTime {
  // Yardımcı methodlar
  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  String _getDayName(int weekday) {
    const days = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];
    return days[weekday % 7];
  }

  String _getMonthName(int month) {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return months[month - 1];
  }

  // Format getter'ları
  String get fullDate => '${_twoDigits(day)}.${_twoDigits(month)}.$year';
  String get fullDateWithTime => '$fullDate ${_twoDigits(hour)}:${_twoDigits(minute)}';
  String get iso8601 => toIso8601String();
  String get timeOnly => '${_twoDigits(hour)}:${_twoDigits(minute)}';
  String get dateOnly => fullDate;
  String get dayMonth => '${_twoDigits(day)}.${_twoDigits(month)}';
  String get monthYear => '${_twoDigits(month)}.$year';
  String get dayName => _getDayName(weekday);
  String get monthName => _getMonthName(month);
  String get dayMonthName => '${_twoDigits(day)} ${_getMonthName(month)}';
  String get dayMonthNameYear => '${_twoDigits(day)} ${_getMonthName(month)} $year';
}
