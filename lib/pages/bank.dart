// SPDX-License-Identifier: MIT
// The bank: statements read from files, the entries not booked yet – by their proposal, or on an account by hand.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../widgets/account_picker.dart';
import '../widgets/common.dart';
import '../widgets/files.dart';
import 'book.dart';

class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final _iban = TextEditingController();
  String? _open;

  @override
  void dispose() {
    _iban.dispose();
    super.dispose();
  }

  static String _key(OpenEntry entry) => '${entry.document}/${entry.entry}';

  Future<void> _read() async {
    final t = context.t;
    final file = await chooseFile(t.statements, const ['xml', 'sta', 'mt940', 'txt', 'csv']);
    if (file == null || !mounted) return;
    final state = AppScope.read(context);
    final iban = _iban.text.trim();
    Imported? imported;
    final ok = await act(context, () async {
      imported = await state.api!.import(
        books: state.books!,
        name: file.name,
        iban: iban.isEmpty ? null : iban,
        file: file.bytes,
      );
    });
    if (ok && mounted && imported != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.imported(imported!.entries, imported!.shownBefore + imported!.known))));
    }
  }

  Future<void> _fetch() async {
    final state = AppScope.read(context);
    await act(context, () => state.api!.fetch(books: state.books!));
  }

  Future<void> _accept(OpenEntry entry) async {
    final state = AppScope.read(context);
    await act(
      context,
      () => state.api!.accept(
        books: state.books!,
        body: EntryRef(document: entry.document, entry: entry.entry),
      ),
      done: context.t.booked,
    );
  }

  Future<void> _acceptAll() async {
    final state = AppScope.read(context);
    final t = context.t;
    Accepted? accepted;
    final ok = await act(context, () async => accepted = await state.api!.acceptAll(books: state.books!));
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.acceptedCount(accepted!.count))));
    }
  }

  String _proposal(BuildContext context, OpenEntry entry) {
    final t = context.t;
    final suggestion = entry.suggestion;
    if (suggestion == null) return '';
    return switch (suggestion.source) {
      'invoice' => '${t.fromInvoice} ${suggestion.number ?? ''}',
      'booked' => '${t.bookedBefore}: ${suggestion.booking.text}',
      // A booking proposed as before has the account it books on first, then VAT, then the bank.
      _ =>
        '${t.asBefore}: ${suggestion.booking.postings.firstOrNull?.number ?? ''} '
            '${suggestion.booking.postings.firstOrNull?.name ?? ''}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final brand = Brand.of(context);
    return PageFrame(
      title: t.bank,
      children: [
        Panel(
          child: FormColumn(
            children: [
              Muted(t.statementHint),
              TextField(
                controller: _iban,
                decoration: InputDecoration(labelText: t.ibanForCsv),
              ),
              ButtonRow([
                FilledButton.icon(
                  onPressed: _read,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(t.readStatement),
                ),
                OutlinedButton(onPressed: _fetch, child: Text(t.fetch)),
              ]),
            ],
          ),
        ),
        Heading(t.openEntries),
        Loaded<(List<OpenEntry>, Choices)>(
          load: (api, books, state) async =>
              (await api.openEntries(books: books), await loadChoices(api, books, state)),
          builder: (context, loaded) {
            final (entries, choices) = loaded;
            if (entries.isEmpty) return Muted(t.noOpenEntries);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (entries.any((e) => e.suggestion != null))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ButtonRow([FilledButton(onPressed: _acceptAll, child: Text(t.acceptAll))]),
                  ),
                Card(
                  child: Column(
                    children: [
                      for (final entry in entries) ...[
                        ListTile(
                          leading: SizedBox(width: 92, child: Text(date(entry.date, state.lang))),
                          title: Text(entry.text),
                          subtitle: entry.suggestion == null
                              ? null
                              : Text(_proposal(context, entry), style: TextStyle(color: brand.accent)),
                          trailing: Money(entry.amount.value),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: ButtonRow([
                            if (entry.suggestion != null)
                              FilledButton(onPressed: () => _accept(entry), child: Text(t.accept)),
                            OutlinedButton(
                              onPressed: () => setState(() => _open = _open == _key(entry) ? null : _key(entry)),
                              child: Text(t.bookEntry),
                            ),
                          ]),
                        ),
                        if (_open == _key(entry))
                          _BookEntry(entry: entry, choices: choices, onBooked: () => setState(() => _open = null)),
                        Divider(height: 1, color: brand.line),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Booking an entry by hand: on an account with a tax code, its amount as the gross.
class _BookEntry extends StatefulWidget {
  const _BookEntry({required this.entry, required this.choices, required this.onBooked});

  final OpenEntry entry;
  final Choices choices;
  final VoidCallback onBooked;

  @override
  State<_BookEntry> createState() => _BookEntryState();
}

class _BookEntryState extends State<_BookEntry> {
  final _form = GlobalKey<FormState>();
  late final _text = TextEditingController(text: widget.entry.text);
  String _account = '';
  String _tax = '';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.read(context);
    final body = BookEntry(
      document: widget.entry.document,
      entry: widget.entry.entry,
      account: _account,
      tax: _tax.isEmpty ? null : _tax,
      text: _text.text.trim(),
    );
    if (await act(
      context,
      () => state.api!.bookEntry(books: state.books!, body: body),
      done: context.t.booked,
    )) {
      widget.onBooked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Form(
        key: _form,
        child: FormColumn(
          children: [
            Input(label: t.text, controller: _text),
            AccountPicker(
              accounts: widget.choices.accounts,
              label: t.account,
              value: _account,
              onChanged: (value) => setState(() => _account = value),
              onChosen: (account) => setState(() => _tax = taxFor(account, widget.choices.codes)),
            ),
            TaxField(codes: widget.choices.codes, value: _tax, onChanged: (value) => setState(() => _tax = value)),
            ButtonRow([FilledButton(onPressed: _book, child: Text(t.bookEntry))]),
          ],
        ),
      ),
    );
  }
}
