// SPDX-License-Identifier: MIT
// Setting up the first books: who they are for, from when, how profit is determined, VAT, the state whose holidays
// move deadlines, and the chart of accounts.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/state.dart';
import '../widgets/common.dart';

class SetUpPage extends StatefulWidget {
  const SetUpPage({super.key});

  @override
  State<SetUpPage> createState() => _SetUpPageState();
}

class _SetUpPageState extends State<SetUpPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _from = '${DateTime.now().year}-01-01';
  String _accounting = 'de-cash-basis';
  String _vatScheme = 'de-regular';
  String _vatBasis = 'cash';
  String _vatPeriod = 'quarter';
  bool _vatExtended = false;
  String _region = '';
  String _chart = 'de-skr03';
  List<RegionView> _regions = const [];
  String? _regionsLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (_regionsLang == state.lang) return;
    _regionsLang = state.lang;
    state.api?.regions(lang: state.lang).then((regions) {
      if (mounted) setState(() => _regions = regions);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.read(context);
    final body = SetUp(
      name: _name.text.trim(),
      from: _from,
      accounting: _accounting,
      vatScheme: _vatScheme,
      vatBasis: _vatBasis,
      vatPeriod: _vatPeriod,
      vatExtended: _vatExtended,
      region: _region.isEmpty ? null : _region,
      chart: _chart,
    );
    if (await act(context, () => state.api!.setUp(body: body))) await state.loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: PageFrame(
        title: t.setUpTitle,
        children: [
          Muted(t.setUpText),
          const SizedBox(height: 16),
          Form(
            key: _form,
            child: FormColumn(
              children: [
                Input(label: t.name, controller: _name),
                DateField(label: t.start, value: _from, onChanged: (value) => _from = value),
                Choice(
                  label: t.accounting,
                  value: _accounting,
                  options: {'de-cash-basis': t.cashBasis, 'de-double-entry': t.doubleEntry},
                  onChanged: (value) => setState(() => _accounting = value),
                ),
                Choice(
                  label: t.vat,
                  value: _vatScheme,
                  options: {'de-regular': t.vatRegular, 'de-small-business': t.vatSmallBusiness},
                  onChanged: (value) => setState(() => _vatScheme = value),
                ),
                if (_vatScheme == 'de-regular') ...[
                  Choice(
                    label: t.vatBasis,
                    value: _vatBasis,
                    options: {'cash': t.vatCash, 'accrual': t.vatAccrual},
                    onChanged: (value) => setState(() => _vatBasis = value),
                  ),
                  Choice(
                    label: t.vatPeriod,
                    value: _vatPeriod,
                    options: {'quarter': t.quarterly, 'month': t.monthly, 'year': t.yearly},
                    onChanged: (value) => setState(() => _vatPeriod = value),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _vatExtended,
                    title: Text(t.vatExtended),
                    onChanged: (value) => setState(() => _vatExtended = value ?? false),
                  ),
                ],
                Choice(
                  label: t.region,
                  value: _region,
                  options: {'': t.noRegion, for (final region in _regions) region.code: region.name},
                  onChanged: (value) => setState(() => _region = value),
                ),
                Choice(
                  label: t.chart,
                  value: _chart,
                  options: const {'de-skr03': 'SKR 03', 'de-skr04': 'SKR 04'},
                  onChanged: (value) => setState(() => _chart = value),
                ),
                ButtonRow([FilledButton(onPressed: _submit, child: Text(t.setUp))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
