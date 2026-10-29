// SPDX-License-Identifier: MIT
// Documents: a file read in – an e-invoice with its booking proposal, anything else filed to book by hand – and the
// documents recorded, each with its original.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../widgets/common.dart';
import '../widgets/files.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String _side = 'purchase';
  String _payment = 'bank';
  ReadDocument? _read;
  String _date = today();
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _choose() async {
    final t = context.t;
    final file = await chooseFile(t.documents, const ['xml', 'pdf', 'jpg', 'jpeg', 'png', 'heic'], images: true);
    if (file == null || !mounted) return;
    final state = AppScope.read(context);
    ReadDocument? read;
    final ok = await act(context, () async {
      read = await state.api!.readDocument(
        books: state.books!,
        name: file.name,
        side: _side,
        payment: _payment,
        file: file.bytes,
      );
    });
    if (!ok || !mounted) return;
    setState(() {
      _read = read;
      _date = today();
      _text.text = read!.proposal?.text ?? read!.document.name ?? '';
    });
  }

  Future<void> _record(bool book) async {
    final read = _read;
    if (read == null) return;
    final state = AppScope.read(context);
    final t = context.t;
    final body = Record(book: book, date: _date, text: _text.text.trim());
    final ok = await act(
      context,
      () => state.api!.record(books: state.books!, pending: read.pending, body: body),
      done: book ? t.booked : t.filed,
    );
    if (ok) setState(() => _read = null);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final read = _read;
    return PageFrame(
      title: t.documents,
      children: [
        Panel(
          child: FormColumn(
            children: [
              Muted(t.documentHint),
              Fields(
                children: [
                  Choice(
                    label: t.direction,
                    value: _side,
                    options: {'purchase': t.purchase, 'sale': t.sale},
                    onChanged: (value) => setState(() => _side = value),
                  ),
                  Choice(
                    label: t.payment,
                    value: _payment,
                    options: {'bank': t.bank, 'cash': t.cash},
                    onChanged: (value) => setState(() => _payment = value),
                  ),
                ],
              ),
              ButtonRow([
                FilledButton.icon(
                  onPressed: _choose,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(t.readDocument),
                ),
              ]),
            ],
          ),
        ),
        if (read != null) ...[
          const SizedBox(height: 16),
          Panel(
            child: FormColumn(
              children: [
                Text(
                  read.document.number ?? read.document.name ?? read.document.id,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (read.notAnInvoice case final why?) Failure('${t.notAnInvoice}: $why'),
                if (read.proposal case final proposal?) ...[
                  DateField(label: t.date, value: _date, onChanged: (value) => _date = value),
                  TextField(
                    controller: _text,
                    decoration: InputDecoration(labelText: t.text),
                  ),
                  Postings(proposal.postings),
                  ButtonRow([
                    FilledButton(onPressed: () => _record(true), child: Text(t.fileAndBook)),
                    OutlinedButton(onPressed: () => _record(false), child: Text(t.fileOnly)),
                  ]),
                ] else ...[
                  Muted(t.noProposal),
                  ButtonRow([
                    FilledButton(onPressed: () => _record(false), child: Text(t.fileOnly)),
                    OutlinedButton(onPressed: () => state.go(Screen.book), child: Text(t.book)),
                  ]),
                ],
              ],
            ),
          ),
        ],
        Heading(t.recorded),
        Loaded<List<DocumentView>>(
          load: (api, books, state) => api.documents(books: books),
          builder: (context, documents) => documents.isEmpty
              ? Muted(t.noDocuments)
              : Card(
                  child: Column(
                    children: [
                      for (final document in documents)
                        ListTile(
                          leading: SizedBox(width: 92, child: Text(date(document.date, state.lang))),
                          title: Text(document.number ?? document.name ?? document.id),
                          subtitle: Text(
                            '${document.format ?? document.mediaType}${document.booked ? '' : ' · ${t.notBooked}'}',
                            style: TextStyle(color: Brand.of(context).muted),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (document.due case final due?) Money(due.value),
                              IconButton(
                                tooltip: t.original,
                                icon: const Icon(Icons.download_outlined),
                                onPressed: () => saveFile(
                                  context,
                                  document.name ?? document.id,
                                  () => state.api!.original(books: state.books!, document: document.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
