# spezado apps

The **desktop and mobile apps** of [spezado](https://spezado.app) – free accounting for everyone – built with Flutter
and licensed under **MIT**.

> **Status: 0.1.0, a preview for the desktop.** The app does what the web app of spezado 0.1.0 does – pairing, setting
> up books, overview, journal with reversals, booking (gross amount or lines), accounts with ledgers and opening
> balances, bank statements and open entries, documents and e-invoices, invoices (XRechnung, ZUGFeRD), reports, review,
> closing and the GoBD export – against **spezado 0.1.0 or later on the same device**; synchronisation between devices,
> new in spezado after 0.1.0, follows. Phones and tablets follow once spezado serves its API to other devices with TLS;
> the plan is in [docs/plan.md](docs/plan.md).

## What they are

- **Desktop** for macOS, Windows and Linux, and **mobile** for iOS and Android – one Flutter code base.
- **Clients of the open spezado API** – they talk to a spezado instance and contain neither the spezado core nor the
  librotenado library. Accounting – validation, bookings, reports, law – runs in spezado only.
- **MIT**, so that they can be distributed through app stores as well; spezado itself stays AGPL-3.0-or-later.

## Try it

You need [spezado](https://github.com/spezado/spezado/releases) 0.1.0 or later on the same device. Start it with
`spezado serve`; it prints the address and a pairing code.

Download the app for your platform from the [releases](https://github.com/spezado/apps/releases), check it against
its SHA-256 file and unpack it:

| Platform | Archive | Start |
|---|---|---|
| macOS 12 or later (Apple silicon and Intel) | `spezado-app-…-macos.zip` | `spezado.app` |
| Windows 10 or later, x86_64 | `spezado-app-…-windows-x86_64.zip` | `spezado.exe` |
| Linux x86_64 or arm64 | `spezado-app-…-linux-….tar.gz` | `spezado` |

The apps are a preview and **not signed** by a publisher yet:

- **macOS** blocks the app at first: open it once, then allow it under *System Settings → Privacy & Security →
  Open Anyway*.
- **Windows** SmartScreen warns about an unknown publisher: *More info → Run anyway*.
- **Linux** needs GTK 3 and libsecret, and a keyring that offers the Secret Service (GNOME Keyring, KWallet) for the
  token.

Or build it yourself with [Flutter](https://docs.flutter.dev/get-started/install) 3.47: `flutter run -d macos` (or
`-d windows`, `-d linux`; Linux needs `libgtk-3-dev` and `libsecret-1-dev`).

Enter the code – or paste the whole link `http://127.0.0.1:8048/#pair=…` into the address. The app keeps its own
token, which `spezado` can revoke (`GET`/`DELETE /api/v1/devices`).

## How it is built

| Path | Content |
|---|---|
| `api/openapi.json` | the description of spezado's API, as spezado publishes it (MIT) |
| `tool/generate.dart` | generates `lib/api/api.g.dart` from it: a class per schema, a method per operation |
| `lib/api/transport.dart` | HTTP with the device's token, files, and the Server-Sent Events that say when books changed |
| `lib/app/` | state, theme in spezado's brand, amounts and dates |
| `lib/pages/`, `lib/widgets/` | the pages and what they share |
| `lib/l10n/` | German and English (`app_de.arb`, `app_en.arb`) |

When spezado's API changes, copy its `api/openapi.json` here and run `dart run tool/generate.dart`; CI checks that
the generated client is up to date. `dart format`, `flutter analyze` and `flutter test` must pass.

The test in `integration_test/` drives the app against a spezado that runs, with a fresh workspace:

```sh
spezado --dir /tmp/ws init && spezado --dir /tmp/ws serve --port 8049
flutter test integration_test -d macos --dart-define=ADDRESS=http://127.0.0.1:8049 --dart-define=CODE=…
```

## Same rules as spezado

- **Everything included** – one edition, every feature free.
- **No telemetry** – only connections that are technically needed or that users start themselves.

## Licence

[MIT](LICENSE), also the description of spezado's API in `api/openapi.json`. The brand's artwork comes from
[spezado/brand](https://github.com/spezado/brand) under CC BY-ND 4.0, the Domitian fonts under OFL-1.1 – see
`REUSE.toml`; spezado's name and brand belong to falkOSS. Contributions with a
[DCO](https://developercertificate.org) sign-off (`git commit -s`), no CLA.

© 2026 falkOSS – Falcon Lake Open Source Software gUG (haftungsbeschränkt) i. G. and the spezado contributors
