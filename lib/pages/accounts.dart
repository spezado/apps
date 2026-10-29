// SPDX-License-Identifier: MIT
// The accounts with a balance at the end of the year, the ledger of each – its bookings with a running balance –
// and the opening balances.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../widgets/account_picker.dart';
import '../widgets/common.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  BalanceView? _account;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final account = _account;
    if (account != null) {
      return PageFrame(
        title: '${t.ledger}: ${account.number ?? ''} ${account.name}',
        actions: [OutlinedButton(onPressed: () => setState(() => _account = null), child: Text(t.back))],
        children: [
          Loaded<List<JournalEntry>>(
            reload: [account.account],
            load: (api, books, state) => api.journal(books: books, year: state.year, lang: state.lang),
            builder: (context, journal) => _Ledger(account: account.account, journal: journal),
          ),
        ],
      );
    }
    return PageFrame(
      title: '${t.accounts} ${state.year}',
      children: [
        Loaded<List<BalanceView>>(
          load: (api, books, state) => api.balances(books: books, year: state.year, lang: state.lang),
          builder: (context, balances) => balances.isEmpty
              ? Muted(t.noBalances)
              : Card(
                  child: Column(
                    children: [
                      for (final row in balances)
                        ListTile(
                          dense: true,
                          leading: SizedBox(width: 56, child: Mono(row.number ?? '')),
                          title: Text(row.name),
                          trailing: Money(row.balance.value),
                          onTap: () => setState(() => _account = row),
                        ),
                    ],
                  ),
                ),
        ),
        const OpeningBalances(),
      ],
    );
  }
}

class _Ledger extends StatelessWidget {
  const _Ledger({required this.account, required this.journal});

  final String account;
  final List<JournalEntry> journal;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang = AppScope.of(context).lang;
    var running = '0.00';
    final rows = [
      for (final entry in journal)
        for (final posting in entry.postings.where((p) => p.account == account))
          (
            date: entry.date,
            text: entry.text,
            amount: posting.amount.value,
            balance: running = sum([running, posting.amount.value]),
          ),
    ];
    if (rows.isEmpty) return Muted(t.nothingBooked);
    final muted = TextStyle(color: Brand.of(context).muted, fontWeight: FontWeight.w600, fontSize: 13);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                Text(t.date, style: muted),
                Text(t.text, style: muted),
                Text(t.amount, style: muted, textAlign: TextAlign.right),
                Text(t.balance, style: muted, textAlign: TextAlign.right),
              ],
            ),
            for (final row in rows)
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(0, 6, 16, 6), child: Text(date(row.date, lang))),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(row.text)),
                  Padding(padding: const EdgeInsets.fromLTRB(16, 6, 0, 6), child: Money(row.amount)),
                  Padding(padding: const EdgeInsets.fromLTRB(16, 6, 0, 6), child: Money(row.balance)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// What accounts held on the first day of the books, booked against the opening balance sheet so that they count in
/// balances and in no result.
class OpeningBalances extends StatefulWidget {
  const OpeningBalances({super.key});

  @override
  State<OpeningBalances> createState() => _OpeningBalancesState();
}

class _OpeningBalancesState extends State<OpeningBalances> {
  final _form = GlobalKey<FormState>();
  bool _editing = false;
  String? _date;
  List<({String account, TextEditingController amount})> _rows = [];

  void _start(String? start) => setState(() {
    _editing = true;
    _date ??= start ?? today();
    _rows = [(account: '', amount: TextEditingController())];
  });

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.read(context);
    final t = context.t;
    final body = Opening(
      date: _date,
      text: t.openingBalances,
      lines: [
        for (final row in _rows) OpeningLine(account: row.account, amount: parseAmount(row.amount.text, state.lang)!),
      ],
    );
    if (await act(
      context,
      () => state.api!.bookOpening(books: state.books!, body: body),
      done: t.booked,
    )) {
      setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang = AppScope.of(context).lang;
    return Loaded<(OpeningView, List<AccountView>)>(
      load: (api, books, state) async =>
          (await api.opening(books: books, lang: state.lang), await api.accounts(books: books, lang: state.lang)),
      builder: (context, loaded) {
        final (view, accounts) = loaded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Heading(t.openingBalances),
            if (view.balances.isEmpty)
              Muted(t.noOpening)
            else
              Card(
                child: Column(
                  children: [
                    for (final row in view.balances)
                      ListTile(
                        dense: true,
                        leading: SizedBox(width: 56, child: Mono(row.number ?? '')),
                        title: Text(row.name),
                        trailing: Money(row.amount.value),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (!_editing)
              ButtonRow([OutlinedButton(onPressed: () => _start(view.start), child: Text(t.enterOpening))])
            else
              Panel(
                child: Form(
                  key: _form,
                  child: FormColumn(
                    children: [
                      Muted(t.openingHint),
                      DateField(label: t.date, value: _date ?? '', onChanged: (value) => _date = value),
                      for (final (i, row) in _rows.indexed)
                        Fields(
                          key: ObjectKey(row.amount),
                          width: 220,
                          children: [
                            AccountPicker(
                              accounts: accounts,
                              label: '${t.account} ${i + 1}',
                              value: row.account,
                              onChanged: (value) => setState(() => _rows[i] = (account: value, amount: row.amount)),
                            ),
                            Input(
                              label: t.amount,
                              controller: row.amount,
                              number: true,
                              validator: (value) => parseAmount(value, lang) == null ? t.amountInvalid : null,
                            ),
                            if (_rows.length > 1)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () => setState(() => _rows.removeAt(i)),
                                  child: Text(t.remove),
                                ),
                              ),
                          ],
                        ),
                      ButtonRow([
                        OutlinedButton(
                          onPressed: () => setState(() => _rows.add((account: '', amount: TextEditingController()))),
                          child: Text(t.addLine),
                        ),
                        OutlinedButton(onPressed: () => setState(() => _editing = false), child: Text(t.cancel)),
                        FilledButton(onPressed: _save, child: Text(t.save)),
                      ]),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
