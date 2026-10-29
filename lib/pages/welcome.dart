// SPDX-License-Identifier: MIT
// The first start on the desktop: install spezado on this device – downloaded, checked, started with its icon in the
// menu bar, paired at once – or connect to a spezado that runs already.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/state.dart';
import '../install/installer.dart';
import '../widgets/common.dart';
import 'pair.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _connect = false;
  bool _atLogin = true;
  double? _progress;
  String? _failure;

  Future<void> _install() async {
    final state = AppScope.read(context);
    final t = context.t;
    setState(() {
      _progress = 0;
      _failure = null;
    });
    try {
      await state.installAndPair(
        atLogin: _atLogin,
        progress: (share) {
          if (mounted) setState(() => _progress = share);
        },
      );
    } on InstallException catch (error) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _failure = error.message == 'running' ? t.alreadyRunning : t.installFailed(error.message);
        if (error.message == 'running') _connect = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = context.t;
    if (_connect || !state.canInstall) {
      return Column(
        children: [
          if (_failure case final failure?)
            Material(
              child: Padding(padding: const EdgeInsets.all(16), child: Failure(failure)),
            ),
          Expanded(
            child: PairPage(
              onBack: state.canInstall
                  ? () => setState(() {
                      _connect = false;
                      _failure = null;
                    })
                  : null,
            ),
          ),
        ],
      );
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final busy = _progress != null;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
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
                Text(t.welcomeTitle, style: Theme.of(context).textTheme.headlineMedium),
                Muted(t.welcomeText),
                Panel(
                  child: FormColumn(
                    children: [
                      Text(t.installTitle, style: Theme.of(context).textTheme.titleLarge),
                      Muted(
                        Installer.hasTray
                            ? t.installText(state.installer.version)
                            : t.installTextNoTray(state.installer.version),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _atLogin,
                        title: Text(t.startAtLogin),
                        onChanged: busy ? null : (value) => setState(() => _atLogin = value ?? true),
                      ),
                      if (busy) LinearProgressIndicator(value: _progress! > 0 && _progress! < 1 ? _progress : null),
                      if (_failure case final failure?) Failure(failure),
                      ButtonRow([FilledButton(onPressed: busy ? null : _install, child: Text(t.installAndStart))]),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : () => setState(() => _connect = true),
                  child: Text(t.connectInstead),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
