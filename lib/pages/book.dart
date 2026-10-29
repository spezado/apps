// SPDX-License-Identifier: MIT
// Booking: a gross amount on an account, split by its tax code against bank or cash – or lines that balance.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../widgets/account_picker.dart';
import '../widgets/common.dart';

/// The accounts and tax codes to choose from.
typedef Choices = ({List<AccountView> accounts, List<TaxCodeView> codes});

Future<Choices> loadChoices(SpezadoApi api, String books, AppState state) async => (
  accounts: await api.accounts(books: books, lang: state.lang),
  codes: await api.taxCodes(books: books, lang: state.lang),
);

/// The tax code that follows the kind of an account chosen, if there is one to choose.
String taxFor(AccountView account, List<TaxCodeView> codes) {
  final code = switch (account.kind) {
    'income' => 'de-out-19',
    'expense' => 'de-in-19',
    _ => '',
  };
  return codes.any((c) => c.code == code) ? code : '';
}

/// A tax code field; empty is none.
class TaxField extends StatelessWidget {
  const TaxField({super.key, required this.codes, required this.value, required this.onChanged, this.short = false});

  final List<TaxCodeView> codes;
  final String value;
  final ValueChanged<String> onChanged;
  final bool short;

  @override
  Widget build(BuildContext context) => Choice(
    label: context.t.taxCode,
    value: value,
    options: {'': context.t.noTax, for (final c in codes) c.code: short ? c.code : '${c.code} – ${c.name}'},
    onChanged: onChanged,
  );
}

class _Row {
  String account = '';
  final amount = TextEditingController();
  String tax = '';
}

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final _form = GlobalKey<FormState>();
  bool _lines = false;
  int _generation = 0;
  String _date = today();
  final _text = TextEditingController();
  String _account = '';
  final _gross = TextEditingController();
  String _tax = '';
  bool _taxTouched = false;
  String _payment = 'bank';
  List<_Row> _rows = [_Row(), _Row()];

  @override
  void dispose() {
    _text.dispose();
    _gross.dispose();
    for (final row in _rows) {
      row.amount.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.read(context);
    final t = context.t;
    final books = state.books!;
    Future<Written> Function() write;
    if (!_lines) {
      final gross = parseAmount(_gross.text, state.lang)!;
      final body = SimpleBooking(
        date: _date,
        text: _text.text.trim(),
        account: _account,
        gross: gross,
        tax: _tax.isEmpty ? null : _tax,
        payment: _payment,
      );
      write = () => state.api!.bookSimple(books: books, body: body);
    } else {
      final lines = [
        for (final row in _rows)
          Line(
            account: row.account,
            amount: parseAmount(row.amount.text, state.lang)!,
            tax: row.tax.isEmpty ? null : row.tax,
          ),
      ];
      write = () => state.api!.bookLines(
        books: books,
        body: LinesBooking(date: _date, text: _text.text.trim(), lines: lines),
      );
    }
    if (!await act(context, write, done: t.booked)) return;
    setState(() {
      _generation++;
      _text.clear();
      _gross.clear();
      _account = '';
      _taxTouched = false;
      for (final row in _rows) {
        row.amount.dispose();
      }
      _rows = [_Row(), _Row()];
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang = AppScope.of(context).lang;
    String? amountValid(String value) => parseAmount(value, lang) == null ? t.amountInvalid : null;
    return PageFrame(
      title: t.book,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(t.simple)),
              ButtonSegment(value: true, label: Text(t.lines)),
            ],
            selected: {_lines},
            onSelectionChanged: (chosen) => setState(() => _lines = chosen.single),
          ),
        ),
        const SizedBox(height: 16),
        Loaded<Choices>(
          load: loadChoices,
          builder: (context, choices) => Form(
            key: _form,
            child: FormColumn(
              children: [
                DateField(label: t.date, value: _date, onChanged: (value) => _date = value),
                Input(label: t.text, controller: _text),
                if (!_lines) ...[
                  AccountPicker(
                    key: ValueKey(('account', _generation)),
                    accounts: choices.accounts,
                    label: t.account,
                    value: _account,
                    onChanged: (value) => setState(() => _account = value),
                    onChosen: (account) {
                      if (!_taxTouched) setState(() => _tax = taxFor(account, choices.codes));
                    },
                  ),
                  Input(label: t.gross, controller: _gross, number: true, validator: amountValid),
                  TaxField(
                    codes: choices.codes,
                    value: _tax,
                    onChanged: (value) => setState(() {
                      _tax = value;
                      _taxTouched = true;
                    }),
                  ),
                  Choice(
                    label: t.payment,
                    value: _payment,
                    options: {'bank': t.bank, 'cash': t.cash},
                    onChanged: (value) => setState(() => _payment = value),
                  ),
                ] else ...[
                  for (final (i, row) in _rows.indexed)
                    Panel(
                      key: ObjectKey(row),
                      padding: const EdgeInsets.all(14),
                      child: Fields(
                        width: 200,
                        children: [
                          AccountPicker(
                            key: ValueKey(('line', _generation, i)),
                            accounts: choices.accounts,
                            label: '${t.account} ${i + 1}',
                            value: row.account,
                            onChanged: (value) => setState(() => row.account = value),
                          ),
                          Input(label: t.amount, controller: row.amount, number: true, validator: amountValid),
                          TaxField(
                            codes: choices.codes,
                            value: row.tax,
                            short: true,
                            onChanged: (value) => setState(() => row.tax = value),
                          ),
                          if (_rows.length > 2)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => setState(() => _rows.remove(row)),
                                child: Text(t.remove),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ButtonRow([
                    OutlinedButton(onPressed: () => setState(() => _rows.add(_Row())), child: Text(t.addLine)),
                  ]),
                  Muted(t.linesHint),
                ],
                ButtonRow([FilledButton(onPressed: _submit, child: Text(t.save))]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
