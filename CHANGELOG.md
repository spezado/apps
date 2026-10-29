# Changelog

## 0.1.0 – 2026-10-29

The first preview, for the desktop, against spezado 0.1.0 on the same device.

- Pairing with the code `spezado serve` shows, or its whole link; a token of the device's own, kept in the keychain
  (on macOS the login keychain) until spezado revokes it.
- Setting up books: profit by cash basis or double entry, VAT, the state whose holidays move deadlines, SKR 03/04.
- Overview, journal with reversals, booking a gross amount or lines, accounts with ledgers and opening balances,
  bank statements (camt.053, MT940, CSV) and open entries, documents and e-invoices, invoices as XRechnung or
  ZUGFeRD, reports with CSV, review, closing and the GoBD export – as in spezado's web app.
- German and English; light, dark or like the system; spezado's brand with Domitian for headings.
- Live: pages read again whenever the books change (Server-Sent Events).
- The client of the API generated from `api/openapi.json` by `tool/generate.dart`.
- Archives for macOS (universal), Windows (x86_64) and Linux (x86_64, arm64) with SHA-256 checksums; not signed by a
  publisher yet.
