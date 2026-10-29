// SPDX-License-Identifier: MIT
// The books at a glance: bank and cash today, income, expenses and result of the year, the next advance VAT return,
// what moves the deadlines, and what waits.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../widgets/common.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    return PageFrame(
      title: t.overview,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Brand.of(context).accent, width: 3)),
          ),
          child: Muted(t.preview),
        ),
        const SizedBox(height: 16),
        Loaded<Overview>(
          load: (api, books, state) => api.overview(books: books, year: state.year, lang: state.lang),
          builder: (context, overview) {
            final result = overview.income != null && overview.expenses != null
                ? subtract(overview.income!.value, overview.expenses!.value)
                : null;
            final vat = overview.nextVatReturn;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Fields(
                  width: 200,
                  children: [
                    _Figure(t.bank, overview.bank?.value),
                    _Figure(t.cash, overview.cash?.value),
                    _Figure('${t.income} ${overview.year}', overview.income?.value),
                    _Figure('${t.expenses} ${overview.year}', overview.expenses?.value),
                    _Figure('${t.result} ${overview.year}', result),
                  ],
                ),
                Heading(t.nextVatReturn),
                if (vat == null)
                  Muted(t.noVatReturns)
                else
                  Text.rich(
                    TextSpan(
                      text: '${date(vat.from, state.lang)} – ${date(vat.to, state.lang)}, ${t.due} ',
                      children: [
                        TextSpan(
                          text: date(vat.due, state.lang),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                const DeadlineFacts(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: Text('${t.openEntries}: ${overview.openEntries}'),
                      onPressed: () => state.go(Screen.bank),
                    ),
                    ActionChip(
                      label: Text('${t.issues}: ${overview.issues}'),
                      onPressed: () => state.go(Screen.review),
                    ),
                    ActionChip(
                      label: Text(
                        '${t.closedUntil}: ${overview.closedUntil == null ? t.nothingClosed : date(overview.closedUntil!, state.lang)}',
                      ),
                      onPressed: () => state.go(Screen.closing),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Muted(label),
        const SizedBox(height: 4),
        Text(
          value == null ? '–' : amount(value!, AppScope.of(context).lang),
          style: const TextStyle(
            fontFamily: serif,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

/// What moves the deadlines – the state whose public holidays apply, the permanent extension of VAT returns – and
/// changing them from a date on.
class DeadlineFacts extends StatefulWidget {
  const DeadlineFacts({super.key});

  @override
  State<DeadlineFacts> createState() => _DeadlineFactsState();
}

class _DeadlineFactsState extends State<DeadlineFacts> {
  ({String from, String region, bool extended})? _form;
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Loaded<(Deadlines, List<RegionView>)>(
      load: (api, books, state) async => (await api.deadlines(books: books), await api.regions(lang: state.lang)),
      builder: (context, loaded) {
        final (current, regions) = loaded;
        String regionName(String? code) =>
            code == null ? t.noRegion : regions.where((r) => r.code == code).firstOrNull?.name ?? code;
        final form = _form;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Text(
                  '${t.region}: ${regionName(current.region)} · ${t.vatExtended}: ${current.vatExtended == true ? t.yes : t.no}',
                ),
                if (form == null)
                  OutlinedButton(
                    onPressed: () => setState(
                      () =>
                          _form = (from: today(), region: current.region ?? '', extended: current.vatExtended ?? false),
                    ),
                    child: Text(t.change),
                  ),
              ],
            ),
            if (form != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Panel(
                  child: Form(
                    key: _key,
                    child: FormColumn(
                      children: [
                        DateField(
                          label: t.validFrom,
                          value: form.from,
                          onChanged: (value) => _form = (from: value, region: _form!.region, extended: _form!.extended),
                        ),
                        Choice(
                          label: t.region,
                          value: form.region,
                          options: {'': t.noRegion, for (final region in regions) region.code: region.name},
                          onChanged: (value) =>
                              setState(() => _form = (from: _form!.from, region: value, extended: _form!.extended)),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: form.extended,
                          title: Text(t.vatExtended),
                          onChanged: (value) => setState(
                            () => _form = (from: _form!.from, region: _form!.region, extended: value ?? false),
                          ),
                        ),
                        ButtonRow([
                          OutlinedButton(onPressed: () => setState(() => _form = null), child: Text(t.cancel)),
                          FilledButton(onPressed: _apply, child: Text(t.apply)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _apply() async {
    final form = _form;
    if (form == null || !_key.currentState!.validate()) return;
    final state = AppScope.read(context);
    final body = Deadlines(
      from: form.from,
      region: form.region.isEmpty ? null : form.region,
      vatExtended: form.extended,
    );
    if (await act(context, () => state.api!.changeDeadlines(books: state.books!, body: body))) {
      setState(() => _form = null);
      state.changed();
    }
  }
}
