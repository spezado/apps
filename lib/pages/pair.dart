// SPDX-License-Identifier: MIT
// Pairing this device with spezado: the address it runs at and the code `spezado serve` shows – or the whole link it
// prints, `http://127.0.0.1:8048/#pair=CODE`, pasted into the address.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../api/transport.dart';
import '../app/state.dart';
import '../widgets/common.dart';

class PairPage extends StatefulWidget {
  const PairPage({super.key});

  @override
  State<PairPage> createState() => _PairPageState();
}

class _PairPageState extends State<PairPage> {
  final _form = GlobalKey<FormState>();
  late final _address = TextEditingController(text: AppScope.read(context).address.toString());
  final _code = TextEditingController();
  final _name = TextEditingController(text: AppState.deviceName());
  bool _busy = false;
  String? _failure;

  @override
  void dispose() {
    _address.dispose();
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  /// A link with `#pair=CODE` gives the code too.
  void _split(String text) {
    final uri = Uri.tryParse(text.trim());
    final code = uri == null ? null : Uri.splitQueryString(uri.fragment)['pair'];
    if (uri == null || code == null) return;
    _address.text = uri.replace(fragment: '', path: '').toString().replaceAll(RegExp(r'#$'), '');
    _code.text = code;
  }

  Future<void> _pair() async {
    if (!_form.currentState!.validate()) return;
    final address = Uri.parse(_address.text.trim());
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await AppScope.read(context).pair(address.replace(path: ''), _code.text.trim(), _name.text.trim());
    } on ApiException catch (error) {
      setState(() => _failure = error.status == 0 ? context.t.unreachable(address.toString()) : error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _form,
              child: FormColumn(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      dark ? 'assets/brand/spezado-lockup-on-dark.svg' : 'assets/brand/spezado-lockup-on-light.svg',
                      height: 56,
                      semanticsLabel: 'spezado',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(t.pairTitle, style: Theme.of(context).textTheme.headlineMedium),
                  Muted(t.pairText),
                  TextFormField(
                    controller: _address,
                    decoration: InputDecoration(labelText: t.address, helperText: t.addressHint),
                    onChanged: _split,
                    validator: (value) {
                      final uri = Uri.tryParse(value?.trim() ?? '');
                      return uri != null && uri.hasScheme && uri.host.isNotEmpty ? null : t.addressInvalid;
                    },
                  ),
                  Input(label: t.code, controller: _code),
                  Input(label: t.deviceName, controller: _name),
                  if (_failure case final failure?) Failure(failure),
                  ButtonRow([FilledButton(onPressed: _busy ? null : _pair, child: Text(t.pair))]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
