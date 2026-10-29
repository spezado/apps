# spezado apps – plan

What the Flutter apps are for, how they relate to spezado and when they are built. The design of spezado itself is
in [spezado/docs/spec.md](https://github.com/spezado/spezado/blob/main/docs/spec.md). Statements marked **OPEN** are
not decided or not verified.

## 1. Place in spezado

spezado is split along one line – the **open API**:

| Part | Repository | Licence | Content |
|---|---|---|---|
| Protocol | `librotenado/librotenado` | MIT, spec CC BY 4.0 | the data model and its rules |
| Core | `spezado/spezado` | AGPL-3.0-or-later | Rust core, CLI and terminal interface, the API, server and relay, the web app (Svelte) |
| Apps | `spezado/apps` (this one) | MIT | desktop and mobile apps (Flutter) |

The apps are **clients of the API only**:

- They contain **no code from the spezado core** and **do not use the librotenado library**. Accounting logic –
  validation, bookings, reports, law – runs in spezado and nowhere else.
- They use a **Dart client generated from the API's OpenAPI description**; nothing of the API is written by hand.
- Being MIT, they can be distributed through **app stores**, which spezado's AGPL is widely held not to allow
  (**OPEN**: review by someone who knows licence law).

## 2. When

After the core and the web app (spezado milestones M0–M3: core, terminal interface for freelancers, bank, API and
web app). Building earlier would mean following an API that is still moving.

**0.1.0** (decided 2026-10-29): the desktop apps, with everything the web app does, against spezado 0.1.0 on the
same device – its API listens on 127.0.0.1 only. The mobile apps follow once spezado serves its API to other
devices with TLS (milestone M4 of spezado).

## 3. Apps

One Flutter code base for:

- **Desktop** – macOS, Windows, Linux: the full working surface, like the web app.
- **Mobile** – iOS, Android: a companion for what happens on the way – photographing and sending receipts, an inbox
  of documents to book, confirming proposed bookings, balances and deadlines at a glance (**OPEN**: final scope).

## 4. Connection

- **Where to:** a spezado instance on the same device (`spezado serve`), in the local network or on a server.
- **Pairing:** each app is paired once by code or QR code and receives its own token, which can be revoked. Accounts
  on servers (passkeys, OIDC) follow spezado's server mode (**OPEN**).
- **Offline:** until spezado synchronises between devices (milestone M5), an app needs a reachable spezado instance.
  Whether the apps later keep a local cache or queue of their own is **OPEN**.

## 5. Principles

- **Everything included** – one edition, every feature free.
- **No telemetry** – only connections that are technically needed or that users start themselves.
- **Brand** from [spezado/brand](https://github.com/spezado/brand), copied, never edited here.

## 6. Open

- Final scope of the mobile app.
- Offline behaviour beyond a reachable spezado instance.
- App store distribution: accounts, signing and review requirements per store.
- Licence review of the split along the API.
