// SPDX-License-Identifier: MIT

import 'package:flutter_test/flutter_test.dart';
import 'package:spezado/app/format.dart';
import 'package:spezado/widgets/account_picker.dart';
import 'package:spezado/api/api.g.dart';

void main() {
  test('amounts as people write them', () {
    expect(amount('-1234567.50', 'de'), '-1.234.567,50');
    expect(amount('-1234567.50', 'en'), '-1,234,567.50');
    expect(amount('12', 'de'), '12');
  });

  test('amounts typed, for the API', () {
    expect(parseAmount('1.234,50', 'de'), '1234.50');
    expect(parseAmount('1234.5', 'de'), '1234.5');
    expect(parseAmount('1,234.50 €', 'en'), '1234.50');
    expect(parseAmount('-19', 'en'), '-19');
    expect(parseAmount('12,345', 'de'), null);
    expect(parseAmount('abc', 'en'), null);
  });

  test('dates and sums', () {
    expect(date('2026-10-29', 'de'), '29.10.2026');
    expect(date('2026-10-29', 'en'), '2026-10-29');
    expect(subtract('1000.00', '1234.56'), '-234.56');
    expect(sum(['0.10', '0.20', '-0.05']), '0.25');
  });

  test('accounts match by number from the start, by name with income and expense first', () {
    const accounts = [
      AccountView(id: 'a', kind: 'asset', name: 'Bank fees receivable', number: '1300'),
      AccountView(id: 'b', kind: 'expense', name: 'Bank fees', number: '4970'),
      AccountView(id: 'c', kind: 'asset', name: 'Bank', number: '1200'),
    ];
    expect(matchAccounts(accounts, '12').map((a) => a.id), ['c']);
    expect(matchAccounts(accounts, 'bank').map((a) => a.id), ['b', 'a', 'c']);
    expect(matchAccounts(accounts, ' '), isEmpty);
  });

  test('the client reads and writes what may be null', () {
    final overview = Overview.fromJson({'year': 2026, 'open_entries': 1, 'issues': 0, 'bank': null});
    expect(overview.bank, isNull);
    expect(overview.toJson(), {'issues': 0, 'open_entries': 1, 'year': 2026});
    const booking = SimpleBooking(account: '8400', date: '2026-10-29', gross: '119.00', payment: 'bank', text: 'x');
    expect(booking.toJson().containsKey('tax'), isFalse);
  });
}
