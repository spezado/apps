// SPDX-License-Identifier: MIT
// The bookings of the year by date; one chosen shows its lines and can be reversed.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../widgets/common.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    return PageFrame(
      title: '${t.journal} ${state.year}',
      children: [
        Loaded<List<JournalEntry>>(
          load: (api, books, state) => api.journal(books: books, year: state.year, lang: state.lang),
          builder: (context, entries) {
            if (entries.isEmpty) return Muted(t.nothingBooked);
            final brand = Brand.of(context);
            return Card(
              child: Column(
                children: [
                  for (final entry in entries) ...[
                    ListTile(
                      selected: entry.event == _selected,
                      selectedColor: brand.text,
                      selectedTileColor: brand.accent.withValues(alpha: 0.12),
                      onTap: () => setState(() => _selected = entry.event == _selected ? null : entry.event),
                      leading: SizedBox(width: 92, child: Text(date(entry.date, state.lang))),
                      title: Text(entry.text),
                      subtitle: entry.reverses != null
                          ? Text(t.reversal)
                          : entry.reversedBy != null
                          ? Text(t.reversed)
                          : null,
                      trailing: Money(entry.amount.value),
                    ),
                    if (entry.event == _selected) _Detail(entry: entry),
                    Divider(height: 1, color: brand.line),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Detail extends StatefulWidget {
  const _Detail({required this.entry});

  final JournalEntry entry;

  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String? _date;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _reverse() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.read(context);
    final body = Reversal(event: widget.entry.event, date: _date!, text: _reason.text.trim());
    if (await act(
      context,
      () => state.api!.reverse(books: state.books!, body: body),
      done: context.t.reversedDone,
    )) {
      setState(() => _date = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final entry = widget.entry;
    final reversible = entry.reverses == null && entry.reversedBy == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Postings(entry.postings),
          if (reversible) ...[
            const SizedBox(height: 12),
            if (_date == null)
              ButtonRow([OutlinedButton(onPressed: () => setState(() => _date = today()), child: Text(t.reverse))])
            else
              Form(
                key: _form,
                child: FormColumn(
                  maxWidth: 480,
                  children: [
                    DateField(label: t.date, value: _date!, onChanged: (value) => _date = value),
                    Input(label: t.reason, controller: _reason),
                    ButtonRow([
                      FilledButton(onPressed: _reverse, child: Text(t.reverse)),
                      OutlinedButton(onPressed: () => setState(() => _date = null), child: Text(t.cancel)),
                    ]),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
