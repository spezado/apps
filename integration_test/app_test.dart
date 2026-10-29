// SPDX-License-Identifier: MIT
// The app against a spezado that runs: pairing, setting up books, booking, and every page shown. Start spezado with
// a fresh workspace first and pass its address and code:
//
//   spezado --dir /tmp/ws init && spezado --dir /tmp/ws serve --port 8049
//   flutter test integration_test -d macos --dart-define=ADDRESS=http://127.0.0.1:8049 --dart-define=CODE=…
//
// Each page is saved as a picture of the app's window in the temporary directory, whose path is printed.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spezado/app/app.dart';
import 'package:spezado/app/state.dart';

const address = String.fromEnvironment('ADDRESS', defaultValue: 'http://127.0.0.1:8049');
const code = String.fromEnvironment('CODE');

/// Lets animations run a while – a spinner never settles.
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

  /// Waits for answers from spezado: pumps until `finder` shows.
  Future<void> until(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    expect(finder, findsWidgets);
  }

  Future<void> go(WidgetTester tester, String page) async {
    final menu = find.byTooltip('Open navigation menu');
    if (menu.evaluate().isNotEmpty) {
      await tester.tap(menu);
      await settle(tester);
    }
    await tester.tap(find.text(page).last);
    await settle(tester);
  }

  testWidgets('pairs, sets up, books and shows every page', (tester) async {
    expect(code, isNotEmpty, reason: 'pass the pairing code with --dart-define=CODE=…');
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await preferences.setString('spezado.lang', 'en');
    await Secrets().setToken(null);
    final state = await AppState.load();
    await tester.binding.setSurfaceSize(const Size(1280, 860));
    await tester.pumpWidget(SpezadoApp(state: state));
    await settle(tester);

    // Where the app could install spezado, it offers that first.
    if (find.text('spezado runs already – connect to it').evaluate().isNotEmpty) {
      await tester.tap(find.text('spezado runs already – connect to it'));
      await settle(tester);
    }
    await picture(tester, '01-pair');
    await tester.enterText(find.widgetWithText(TextFormField, 'Address of spezado'), address);
    await tester.enterText(find.widgetWithText(TextFormField, 'Pairing code'), code);
    await tester.tap(find.widgetWithText(FilledButton, 'Pair'));
    await until(tester, find.text('Set up the books'));
    expect(await tester.runAsync(Secrets().token), isNotNull, reason: 'the token in the keychain');
    expect(preferences.getKeys().where((key) => key.contains('token')), isEmpty);

    await picture(tester, '02-set-up');
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Erika Mustermann');
    await tester.tap(find.widgetWithText(FilledButton, 'Set up'));
    await until(tester, find.text('Next advance VAT return'));
    await picture(tester, '03-overview');

    await go(tester, 'Book');
    await tester.enterText(find.widgetWithText(TextFormField, 'Text'), 'Consulting');
    await tester.enterText(find.widgetWithText(TextFormField, 'Account'), '8400');
    await settle(tester);
    await tester.tap(find.text('8400').last);
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Gross amount'), '1190');
    await picture(tester, '04-book');
    await tester.tap(find.widgetWithText(FilledButton, 'Book').last);
    await until(tester, find.text('Booked.'));

    await go(tester, 'Journal');
    await until(tester, find.text('Consulting'));
    await tester.tap(find.text('Consulting'));
    await picture(tester, '05-journal');

    for (final (page, name) in [
      ('Overview', '06-overview'),
      ('Bank', '07-bank'),
      ('Documents', '08-documents'),
      ('Invoices', '09-invoices'),
      ('Accounts', '10-accounts'),
      ('Reports', '11-reports'),
      ('Review', '12-review'),
      ('Closing', '13-closing'),
    ]) {
      await go(tester, page);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 600)));
      await picture(tester, name);
    }

    state.setLang('de');
    state.setTheme(ThemeMode.dark);
    await go(tester, 'Übersicht');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 600)));
    await picture(tester, '14-overview-de-dark');
    // ignore: avoid_print
    print('PICTURES ${pictures.path}');
  });
}
