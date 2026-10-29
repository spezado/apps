// SPDX-License-Identifier: MIT
// Amounts and dates between the API and people: the API writes `-1234.50` and `2026-10-29`, people of a language
// write `-1.234,50` and `29.10.2026`.

/// An amount from the API as people of `lang` write it.
String amount(String value, String lang) {
  final negative = value.startsWith('-');
  final parts = (negative ? value.substring(1) : value).split('.');
  final (group, point) = lang == 'de' ? ('.', ',') : (',', '.');
  final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => group);
  return '${negative ? '-' : ''}$whole${parts.length > 1 ? point + parts[1] : ''}';
}

/// An amount typed, with or without separators of thousands, for the API: `1234.50`; null if it is none.
String? parseAmount(String text, String lang) {
  var plain = text.trim().replaceAll(RegExp(r'[\s€]'), '');
  plain = lang == 'de' && plain.contains(',')
      ? plain.replaceAll('.', '').replaceFirst(',', '.')
      : plain.replaceAll(',', '');
  return RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(plain) ? plain : null;
}

/// A date from the API (`YYYY-MM-DD`) as people of `lang` write it.
String date(String value, String lang) {
  if (lang != 'de') return value;
  final parts = value.split('-');
  return parts.length == 3 ? '${parts[2]}.${parts[1]}.${parts[0]}' : value;
}

/// A day as the API writes it.
String isoDate(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

/// Today by the device's clock.
String today() => isoDate(DateTime.now());

/// The difference of two amounts from the API, in cents, as the API writes amounts.
String subtract(String a, String b) => _fromCents(_cents(a) - _cents(b));

/// Amounts from the API added up.
String sum(Iterable<String> values) => _fromCents(values.fold(0, (total, value) => total + _cents(value)));

int _cents(String value) {
  final negative = value.startsWith('-');
  final parts = (negative ? value.substring(1) : value).split('.');
  final fraction = (parts.length > 1 ? parts[1] : '').padRight(2, '0').substring(0, 2);
  final cents = int.parse(parts.first) * 100 + int.parse(fraction);
  return negative ? -cents : cents;
}

String _fromCents(int cents) {
  final whole = (cents.abs() ~/ 100).toString();
  final fraction = (cents.abs() % 100).toString().padLeft(2, '0');
  return '${cents < 0 ? '-' : ''}$whole.$fraction';
}
