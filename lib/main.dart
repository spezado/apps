// SPDX-License-Identifier: MIT
// spezado – the desktop and mobile apps: clients of spezado's open API.

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SpezadoApp(state: await AppState.load()));
}
