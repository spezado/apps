// SPDX-License-Identifier: MIT
// spezado on this device, for the desktop app: downloaded once from its release, checked against the SHA-256 pinned
// in the app, unpacked into the app's support directory, and started – with its icon in the menu bar where it has
// one (`spezado tray`), else as the server alone (`spezado serve`). It runs on its own: closing the app leaves it
// running, and it can start at login.

import 'dart:ffi' show Abi;
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'release.g.dart';

class Installer {
  Installer({this.binaryOverride, this.directory, this.port = 8048});

  /// A spezado program to use instead of downloading one – for tests and development.
  final String? binaryOverride;

  /// The workspace directory spezado works in; its default when null.
  final String? directory;

  /// Where spezado listens when the app starts it.
  final int port;

  /// The address spezado answers at when the app starts it.
  Uri get address => Uri.parse('http://127.0.0.1:$port');

  List<String> get _directory => [
    if (directory case final directory?) ...['--dir', directory],
  ];

  /// The platform as the pinned archives name it; null where spezado has no release.
  static String? get platform => switch (Abi.current()) {
    Abi.macosArm64 => 'macos-arm64',
    Abi.windowsX64 => 'windows-x64',
    Abi.linuxX64 => 'linux-x64',
    Abi.linuxArm64 => 'linux-arm64',
    _ => null,
  };

  /// Whether this device can have spezado installed by the app.
  bool get supported => binaryOverride != null || spezadoArchives.containsKey(platform);

  /// The version the app installs.
  String get version => binaryOverride == null ? spezadoVersion : 'local';

  /// Whether this build of spezado has an icon in the menu bar; the Linux releases have none.
  static bool get hasTray => !Platform.isLinux;

  Future<Directory> _home() async => Directory('${(await getApplicationSupportDirectory()).path}/spezado/$version');

  /// The program, if installed.
  Future<File?> binary() async {
    if (binaryOverride case final path?) return File(path);
    final file = File('${(await _home()).path}/spezado${Platform.isWindows ? '.exe' : ''}');
    return await file.exists() ? file : null;
  }

  /// Downloads, checks and unpacks spezado; `progress` hears the share done, 0 to 1. Throws what went wrong.
  Future<File> install({void Function(double share)? progress}) async {
    if (await binary() case final installed?) return installed;
    final archive = spezadoArchives[platform] ?? (throw const InstallException('no spezado release for this device'));
    final home = await _home();
    await home.create(recursive: true);
    final url = Uri.parse('https://github.com/spezado/spezado/releases/download/v$spezadoVersion/${archive.file}');
    final client = http.Client();
    final List<int> bytes;
    try {
      final response = await client.send(http.Request('GET', url));
      if (response.statusCode != 200) throw InstallException('$url: ${response.statusCode}');
      final total = response.contentLength ?? 0;
      final received = <int>[];
      await for (final chunk in response.stream) {
        received.addAll(chunk);
        if (total > 0) progress?.call(received.length / total);
      }
      bytes = received;
    } on SocketException catch (error) {
      throw InstallException('$url: ${error.message}');
    } finally {
      client.close();
    }
    if (sha256.convert(bytes).toString() != archive.sha256) {
      throw InstallException('${archive.file}: the checksum does not match – not installed');
    }
    final unpacked = await Directory.systemTemp.createTemp('spezado-');
    try {
      final file = File('${unpacked.path}/${archive.file}');
      await file.writeAsBytes(bytes);
      // tar unpacks both: .tar.gz, and on Windows (bsdtar) .zip.
      final tar = await Process.run('tar', ['-xf', file.path, '-C', unpacked.path]);
      if (tar.exitCode != 0) throw InstallException('tar: ${tar.stderr}');
      final folder = archive.file.replaceAll(RegExp(r'\.(tar\.gz|zip)$'), '');
      await for (final entry in Directory('${unpacked.path}/$folder').list()) {
        final name = entry.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);
        if (entry is File) await entry.copy('${home.path}/$name');
        if (entry is Directory) await _copy(entry, Directory('${home.path}/$name'));
      }
    } finally {
      await unpacked.delete(recursive: true);
    }
    final program = File('${home.path}/spezado${Platform.isWindows ? '.exe' : ''}');
    if (!Platform.isWindows) await Process.run('chmod', ['+x', program.path]);
    progress?.call(1);
    return program;
  }

  static Future<void> _copy(Directory from, Directory to) async {
    await to.create(recursive: true);
    await for (final entry in from.list()) {
      final name = entry.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);
      if (entry is File) await entry.copy('${to.path}/$name');
      if (entry is Directory) await _copy(entry, Directory('${to.path}/$name'));
    }
  }

  /// A pairing code the app makes up and gives spezado when starting it.
  static String newPairingCode() {
    final random = Random.secure();
    return List.generate(24, (_) => random.nextInt(16).toRadixString(16)).join();
  }

  /// Starts spezado on its own, so that it keeps running when the app closes; with `pairing` as its pairing code.
  Future<void> start({String? pairing}) async {
    final program = await binary() ?? (throw const InstallException('spezado is not installed'));
    await Process.start(
      program.path,
      [..._directory, hasTray ? 'tray' : 'serve', '--port', '$port'],
      environment: {'SPEZADO_PAIRING_CODE': ?pairing},
      mode: ProcessStartMode.detached,
    );
  }

  /// Starts spezado at login, or stops doing so.
  Future<void> autostart(bool on) async {
    final program = await binary() ?? (throw const InstallException('spezado is not installed'));
    final result = await Process.run(program.path, [..._directory, 'autostart', on ? 'on' : 'off', '--port', '$port']);
    if (result.exitCode != 0) throw InstallException('spezado autostart: ${result.stderr}');
  }

  /// Whether spezado answers at `address`.
  static Future<bool> answers(Uri address) async {
    try {
      final response = await http
          .get(address.replace(path: '/api/v1/openapi.json'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }
}

class InstallException implements Exception {
  const InstallException(this.message);

  final String message;

  @override
  String toString() => message;
}
