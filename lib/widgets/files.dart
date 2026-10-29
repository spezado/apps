// SPDX-License-Identifier: MIT
// Files in and out: a file chosen to send to spezado, and bytes from spezado saved where people choose.

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'common.dart';

/// A file chosen: its name and content.
typedef Chosen = ({String name, Uint8List bytes});

/// Lets people choose a file of the kinds given; null if they chose none.
Future<Chosen?> chooseFile(String label, List<String> extensions, {bool images = false}) async {
  final file = await openFile(
    acceptedTypeGroups: [
      XTypeGroup(
        label: label,
        extensions: extensions,
        uniformTypeIdentifiers: images ? const ['public.image', 'public.xml', 'com.adobe.pdf'] : null,
      ),
    ],
  );
  if (file == null) return null;
  return (name: file.name, bytes: await file.readAsBytes());
}

/// Fetches a file from spezado and saves it where people choose.
Future<void> saveFile(BuildContext context, String name, Future<Uint8List> Function() fetch) async {
  final messenger = ScaffoldMessenger.of(context);
  final t = context.t;
  await act(context, () async {
    final bytes = await fetch();
    final location = await getSaveLocation(suggestedName: name);
    if (location == null) return;
    await XFile.fromData(bytes, name: name).saveTo(location.path);
    messenger.showSnackBar(SnackBar(content: Text(t.saved(location.path))));
  });
}
