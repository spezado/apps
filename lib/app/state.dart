// SPDX-License-Identifier: MIT
// The state of the app: where spezado runs and the token of this device, language and appearance, the books shown,
// the year – and a counter that grows whenever the books change, so that pages read again. The token is kept in the
// system's store of secrets (the keychain on macOS and iOS); everything else in the app's preferences.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.g.dart';
import '../api/transport.dart';

/// Where `spezado serve` runs by default.
final defaultAddress = Uri.parse('http://127.0.0.1:8048');

enum Screen { overview, journal, bank, documents, invoices, accounts, reports, review, closing, book }

class AppState extends ChangeNotifier {
  AppState(this._preferences, this._secrets, {String? token})
    : lang =
          _preferences.getString(_langKey) ?? (PlatformDispatcher.instance.locale.languageCode == 'de' ? 'de' : 'en'),
      theme = ThemeMode.values.asNameMap()[_preferences.getString(_themeKey)] ?? ThemeMode.system {
    final address = Uri.tryParse(_preferences.getString(_addressKey) ?? '');
    if (address != null && token != null) _connect(address, token);
  }

  /// The state as this device left it.
  static Future<AppState> load() async {
    final secrets = Secrets();
    return AppState(await SharedPreferences.getInstance(), secrets, token: await secrets.token());
  }

  static const _addressKey = 'spezado.address';
  static const _langKey = 'spezado.lang';
  static const _themeKey = 'spezado.theme';

  final SharedPreferences _preferences;
  final Secrets _secrets;

  String lang;
  ThemeMode theme;
  Screen page = Screen.overview;
  int year = DateTime.now().year;

  /// Grows whenever the books change.
  int version = 0;

  Transport? _transport;
  StreamSubscription<String>? _changes;

  /// The API, once this device is paired.
  SpezadoApi? api;

  /// The books of the workspace; null until read.
  List<BooksSummary>? allBooks;

  /// What went wrong reading them.
  String? failure;

  bool get paired => api != null;

  /// The books shown: the first of the workspace.
  BooksSummary? get current => allBooks?.firstOrNull;
  String? get books => current?.id;

  void _connect(Uri address, String token) {
    _transport = Transport(address, token: token);
    api = SpezadoApi(_transport!);
    _changes = _transport!.changes().listen((_) => changed());
    loadBooks();
  }

  /// Pairs this device with the code `spezado serve` shows; throws what went wrong.
  Future<void> pair(Uri address, String code, String name) async {
    final transport = Transport(address);
    try {
      final paired = await SpezadoApi(transport).pair(
        body: PairRequest(code: code, name: name),
      );
      await _secrets.setToken(paired.token);
      await _preferences.setString(_addressKey, address.toString());
      _connect(address, paired.token);
    } finally {
      transport.close();
    }
    notifyListeners();
  }

  /// Forgets the token, for example when spezado revoked it.
  Future<void> unpair() async {
    await _changes?.cancel();
    _transport?.close();
    _transport = null;
    api = null;
    allBooks = null;
    await _secrets.setToken(null);
    notifyListeners();
  }

  /// The address paired with, or the default.
  Uri get address => Uri.tryParse(_preferences.getString(_addressKey) ?? '') ?? defaultAddress;

  Future<void> loadBooks() async {
    final api = this.api;
    if (api == null) return;
    try {
      allBooks = await api.books();
      failure = null;
    } on ApiException catch (error) {
      if (error.unauthorised) return unpair();
      failure = error.message;
    }
    notifyListeners();
  }

  /// The books changed: pages read again.
  void changed() {
    version++;
    loadBooks();
  }

  void go(Screen to) {
    page = to;
    notifyListeners();
  }

  void setYear(int to) {
    year = to;
    notifyListeners();
  }

  void setLang(String to) {
    lang = to;
    _preferences.setString(_langKey, to);
    notifyListeners();
  }

  void setTheme(ThemeMode to) {
    theme = to;
    _preferences.setString(_themeKey, to.name);
    notifyListeners();
  }

  /// A name for this device when pairing.
  static String deviceName() {
    try {
      return 'spezado ${Platform.operatingSystem} ${Platform.localHostname}'.trim();
    } on Object {
      return 'spezado app';
    }
  }

  @override
  void dispose() {
    _changes?.cancel();
    _transport?.close();
    super.dispose();
  }
}

/// Hands the state down the tree; widgets that read it rebuild when it changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// The state without rebuilding when it changes – for callbacks.
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// The token of this device in the system's store of secrets. On macOS the login keychain, not the data protection
/// keychain: that one needs Keychain Sharing and with it a provisioning profile for every Mac the app runs on.
class Secrets {
  Secrets([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(accountName: 'spezado'),
            mOptions: MacOsOptions(accountName: 'spezado', usesDataProtectionKeychain: false),
          );

  static const _tokenKey = 'spezado.token';

  final FlutterSecureStorage _storage;

  Future<String?> token() => _storage.read(key: _tokenKey);

  Future<void> setToken(String? token) =>
      token == null ? _storage.delete(key: _tokenKey) : _storage.write(key: _tokenKey, value: token);
}
