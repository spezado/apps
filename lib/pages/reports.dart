// SPDX-License-Identifier: MIT
// The reports of the year – the advance VAT returns with their deadlines, the annual ones – and their figures, which
// can be saved as CSV.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../widgets/common.dart';
import '../widgets/files.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportItem? _open;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final open = _open;
    if (open != null) {
      return Loaded<Figures>(
        reload: [open.id, open.from],
        load: (api, books, state) =>
            api.report(books: books, report: open.id, from: open.from, to: open.to, lang: state.lang),
        builder: (context, figures) => PageFrame(
          title: figures.name,
          actions: [
            OutlinedButton(onPressed: () => setState(() => _open = null), child: Text(t.back)),
            OutlinedButton(onPressed: () => _csv(figures, open), child: Text(t.csv)),
          ],
          children: [
            Text('${date(open.from, state.lang)} – ${date(open.to, state.lang)}'),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: t.draft,
                style: TextStyle(color: Brand.of(context).error),
                children: [
                  TextSpan(
                    text: ' · ${figures.law}',
                    style: TextStyle(color: Brand.of(context).muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  for (final field in figures.fields)
                    ListTile(
                      dense: true,
                      leading: SizedBox(width: 120, child: Mono(field.field)),
                      title: Text(field.name ?? ''),
                      trailing: Money(field.amount.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return PageFrame(
      title: '${t.reports} ${state.year}',
      children: [
        Loaded<List<ReportItem>>(
          load: (api, books, state) => api.reports(books: books, year: state.year, lang: state.lang),
          builder: (context, reports) => reports.isEmpty
              ? Muted(t.noReports)
              : Card(
                  child: Column(
                    children: [
                      for (final item in reports)
                        ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${date(item.from, state.lang)} – ${date(item.to, state.lang)}'
                            '${item.due == null ? '' : ' · ${t.due} ${date(item.due!, state.lang)}'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => setState(() => _open = item),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _csv(Figures figures, ReportItem item) {
    String quote(String text) => '"${text.replaceAll('"', '""')}"';
    final lines = [
      'field;name;amount',
      for (final field in figures.fields) '${field.field};${quote(field.name ?? '')};${field.amount.value}',
    ];
    return saveFile(
      context,
      '${figures.id}-${item.from}-${item.to}.csv',
      () async => Uint8List.fromList(utf8.encode('${lines.join('\n')}\n')),
    );
  }
}
