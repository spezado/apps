// SPDX-License-Identifier: MIT
// Closing a period, and the data transfer of the GoBD for an auditor.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../widgets/common.dart';
import '../widgets/files.dart';

class ClosingPage extends StatefulWidget {
  const ClosingPage({super.key});

  @override
  State<ClosingPage> createState() => _ClosingPageState();
}

class _ClosingPageState extends State<ClosingPage> {
  final _closeForm = GlobalKey<FormState>();
  final _exportForm = GlobalKey<FormState>();
  late String _to = () {
    final now = DateTime.now();
    return isoDate(DateTime(now.year, now.month, 0));
  }();
  int? _year;
  late String _from;
  late String _until;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final year = AppScope.of(context).year;
    if (_year == year) return;
    _year = year;
    _from = '$year-01-01';
    _until = '$year-12-31';
  }

  Future<void> _close() async {
    if (!_closeForm.currentState!.validate()) return;
    final state = AppScope.read(context);
    await act(
      context,
      () => state.api!.close(
        books: state.books!,
        body: Close(to: _to),
      ),
      done: '${context.t.closed}: ${date(_to, state.lang)}',
    );
  }

  Future<void> _export() async {
    if (!_exportForm.currentState!.validate()) return;
    final state = AppScope.read(context);
    await saveFile(
      context,
      'gobd-$_from-$_until.zip',
      () => state.api!.gobd(books: state.books!, from: _from, to: _until),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    return PageFrame(
      title: t.closing,
      children: [
        Loaded<Overview>(
          load: (api, books, state) => api.overview(books: books, year: state.year),
          builder: (context, overview) => Text(
            '${t.closedUntil}: ${overview.closedUntil == null ? t.nothingClosed : date(overview.closedUntil!, state.lang)}',
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Form(
            key: _closeForm,
            child: FormColumn(
              maxWidth: 420,
              children: [
                Muted(t.closeHint),
                DateField(label: t.closeUpTo, value: _to, onChanged: (value) => _to = value),
                ButtonRow([FilledButton(onPressed: _close, child: Text(t.close))]),
              ],
            ),
          ),
        ),
        Heading(t.gobd),
        Panel(
          child: Form(
            key: _exportForm,
            child: FormColumn(
              maxWidth: 420,
              children: [
                Muted(t.gobdHint),
                DateField(
                  key: ValueKey(('from', _year)),
                  label: t.from,
                  value: _from,
                  onChanged: (value) => _from = value,
                ),
                DateField(
                  key: ValueKey(('to', _year)),
                  label: t.to,
                  value: _until,
                  onChanged: (value) => _until = value,
                ),
                ButtonRow([FilledButton(onPressed: _export, child: Text(t.exportZip))]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
