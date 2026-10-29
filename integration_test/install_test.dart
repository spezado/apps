// SPDX-License-Identifier: MIT
// The first start on the desktop: the app starts a spezado program itself, pairs with it and sets up books – with a
// local build instead of a download, a workspace of its own and a free port:
//
//   flutter test integration_test/install_test.dart -d macos --dart-define=SPEZADO_BINARY=/path/to/spezado \
//     --dart-define=SPEZADO_DIR=/tmp/ws --dart-define=SPEZADO_PORT=8053
//
// Without SPEZADO_BINARY it downloads the pinned release, as people get it.
//
// spezado keeps running afterwards, as it should; stop it with "Quit spezado" in the menu bar.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spezado/app/app.dart';
import 'package:spezado/app/state.dart';
import 'package:spezado/install/installer.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final pictures = Directory.systemTemp.createTempSync('spezado-pictures-');

  Future<void> picture(WidgetTester tester, String name) async {
    await settle(tester);
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${pictures.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> until(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    expect(finder, findsWidgets);
  }

  testWidgets('installs spezado, starts it, pairs and sets up books', (tester) async {
    expect(const String.fromEnvironment('SPEZADO_DIR'), isNotEmpty, reason: 'pass --dart-define=SPEZADO_DIR');
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await preferences.setString('spezado.lang', 'en');
    await Secrets().setToken(null);
    final state = await AppState.load();
    expect(await Installer.answers(state.installer.address), isFalse, reason: 'the port must be free');
    await tester.pumpWidget(SpezadoApp(state: state));
    await settle(tester);

    await picture(tester, '01-welcome');
    await tester.tap(find.text('Start spezado when I log in'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Install and start'));
    await until(tester, find.text('Set up the books'));
    expect(await Installer.answers(state.installer.address), isTrue);
    expect(await tester.runAsync(Secrets().token), isNotNull);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Erika Mustermann');
    await tester.tap(find.widgetWithText(FilledButton, 'Set up'));
    await until(tester, find.text('Next advance VAT return'));
    await picture(tester, '02-overview');
    // ignore: avoid_print
    print('PICTURES ${pictures.path}');
  });
}
