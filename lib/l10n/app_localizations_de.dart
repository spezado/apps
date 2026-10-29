// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get accept => 'Übernehmen';

  @override
  String get acceptAll => 'Alle Vorschläge übernehmen';

  @override
  String acceptedCount(int count) {
    return 'Gebucht: $count';
  }

  @override
  String get account => 'Konto';

  @override
  String get accounting => 'Gewinnermittlung';

  @override
  String get accounts => 'Konten';

  @override
  String get addLine => 'Zeile hinzufügen';

  @override
  String get address => 'Adresse von spezado';

  @override
  String get addressHint => 'Zeigt `spezado serve` an; der Link mit #pair=… trägt auch den Code ein';

  @override
  String get addressInvalid => 'Eine Adresse wie http://127.0.0.1:8048';

  @override
  String get amount => 'Betrag';

  @override
  String get amountInvalid => 'Ein Betrag wie 1234,50';

  @override
  String get apply => 'Übernehmen';

  @override
  String get asBefore => 'Wie zuletzt';

  @override
  String get back => 'Zurück';

  @override
  String get balance => 'Saldo';

  @override
  String get bank => 'Bank';

  @override
  String get book => 'Buchen';

  @override
  String get bookEntry => 'Selbst buchen';

  @override
  String get booked => 'Gebucht.';

  @override
  String get bookedBefore => 'Schon gebucht';

  @override
  String get buyerReference => 'Käuferreferenz (Leitweg-ID)';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cash => 'Kasse';

  @override
  String get cashBasis => 'Einnahmenüberschussrechnung (EÜR)';

  @override
  String get change => 'Ändern';

  @override
  String get chart => 'Kontenrahmen';

  @override
  String get chooseAccount => 'Ein Konto aus der Liste wählen';

  @override
  String get chooseCustomer => 'Einen Kunden wählen';

  @override
  String get city => 'Ort';

  @override
  String get close => 'Abschließen';

  @override
  String get closeHint => 'Bis zu diesem Tag lässt sich danach nichts mehr buchen; Korrekturen werden später gebucht.';

  @override
  String get closeUpTo => 'Abschließen bis';

  @override
  String get closed => 'Abgeschlossen bis';

  @override
  String get closedUntil => 'Abgeschlossen bis';

  @override
  String get closing => 'Abschluss';

  @override
  String get code => 'Kopplungscode';

  @override
  String get contact => 'Ansprechpartner';

  @override
  String get country => 'Land (ISO-Code)';

  @override
  String get countryInvalid => 'Zwei Buchstaben: DE, AT, FR …';

  @override
  String get csv => 'Als CSV sichern';

  @override
  String get customer => 'Kunde';

  @override
  String get date => 'Datum';

  @override
  String get days => 'Tage';

  @override
  String get deliveryDate => 'Leistungsdatum';

  @override
  String get deviceName => 'Name dieses Geräts';

  @override
  String get direction => 'Richtung';

  @override
  String get documentHint =>
      'Eine E-Rechnung (XRechnung, ZUGFeRD) bringt einen Buchungsvorschlag mit; ein PDF oder Foto wird abgelegt und selbst gebucht.';

  @override
  String get documents => 'Belege';

  @override
  String get doubleEntry => 'Doppelte Buchführung (Bilanz)';

  @override
  String get draft => 'Entwurf – noch nicht von Steuerberatern geprüft';

  @override
  String get due => 'fällig';

  @override
  String get email => 'E-Mail';

  @override
  String get enterOpening => 'Anfangsbestände eingeben';

  @override
  String get exemptionReason => 'Grund der Steuerbefreiung';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get exportZip => 'ZIP sichern';

  @override
  String get fetch => 'Von der Bank abrufen';

  @override
  String get fileAndBook => 'Ablegen und buchen';

  @override
  String get fileOnly => 'Nur ablegen';

  @override
  String get filed => 'Abgelegt.';

  @override
  String get from => 'Von';

  @override
  String get fromInvoice => 'Zahlt Rechnung';

  @override
  String get gobd => 'Datenüberlassung für die Betriebsprüfung (GoBD)';

  @override
  String get gobdHint => 'Buchungen, Konten und Belege eines Zeitraums als ZIP-Datei (Z3).';

  @override
  String get gross => 'Bruttobetrag';

  @override
  String get hours => 'Stunden';

  @override
  String get ibanForCsv => 'IBAN – nur für die CSV-Datei einer Bank';

  @override
  String imported(int entries, int known) {
    return 'Neue Umsätze: $entries · schon bekannt: $known';
  }

  @override
  String get income => 'Einnahmen';

  @override
  String get invoiceFile => 'Datei';

  @override
  String get invoiceWritten => 'Rechnung geschrieben';

  @override
  String get invoices => 'Rechnungen';

  @override
  String get issues => 'Zu klären';

  @override
  String get journal => 'Journal';

  @override
  String get keep => 'Speichern';

  @override
  String get ledger => 'Kontoblatt';

  @override
  String get lines => 'Zeilen';

  @override
  String get linesHint => 'Soll positiv, Haben negativ; die Zeilen müssen null ergeben.';

  @override
  String get monthly => 'Monatlich';

  @override
  String get name => 'Name';

  @override
  String get newCustomer => 'Neuer Kunde';

  @override
  String get newInvoice => 'Neue Rechnung';

  @override
  String get nextVatReturn => 'Nächste Umsatzsteuer-Voranmeldung';

  @override
  String get nextYear => 'Nächstes Jahr';

  @override
  String get no => 'nein';

  @override
  String get noBalances => 'Kein Konto hat in diesem Jahr einen Saldo.';

  @override
  String get noDocuments => 'Noch keine Belege.';

  @override
  String get noOpenEntries => 'Alle Umsätze sind gebucht.';

  @override
  String get noOpening => 'Keine Anfangsbestände gebucht.';

  @override
  String get noProposal => 'Kein Vorschlag – ablegen und selbst buchen.';

  @override
  String get noRegion => 'Kein Bundesland';

  @override
  String get noReports => 'Keine Meldungen in diesem Jahr.';

  @override
  String get noTax => 'Kein Steuerschlüssel';

  @override
  String get noVatReturns => 'Keine Umsatzsteuer-Voranmeldungen.';

  @override
  String get notAnInvoice => 'Nicht als E-Rechnung gelesen';

  @override
  String get notBooked => 'nicht gebucht';

  @override
  String get note => 'Hinweis';

  @override
  String get nothingBooked => 'Noch nichts gebucht.';

  @override
  String get nothingClosed => 'nichts';

  @override
  String get nothingToReview => 'Nichts zu klären.';

  @override
  String get numberInvalid => 'Eine ganze Zahl';

  @override
  String get numberPrefix => 'Präfix der Rechnungsnummern';

  @override
  String offline(String address) {
    return 'spezado antwortet nicht unter $address. Läuft `spezado serve`?';
  }

  @override
  String get openEntries => 'Offene Umsätze';

  @override
  String get openingBalances => 'Anfangsbestände';

  @override
  String get openingHint =>
      'Was die Konten am ersten Tag der Bücher hatten – positiv für Vermögen, negativ für Schulden.';

  @override
  String get original => 'Original sichern';

  @override
  String get otherLanguage => 'English';

  @override
  String get overview => 'Übersicht';

  @override
  String get pair => 'Koppeln';

  @override
  String get pairAgain => 'Neu koppeln';

  @override
  String get pairText =>
      'Starte spezado auf diesem Gerät mit `spezado serve` und gib den Code ein, den es zeigt. Die App bekommt ein eigenes Token, das spezado widerrufen kann.';

  @override
  String get pairTitle => 'Mit spezado koppeln';

  @override
  String get payment => 'Bezahlt über';

  @override
  String get paymentDays => 'Zahlungsziel in Tagen';

  @override
  String get phone => 'Telefon';

  @override
  String get pieces => 'Stück';

  @override
  String get postcode => 'PLZ';

  @override
  String get preview =>
      'Vorschau: spezado 0.1 ist zum Ausprobieren. Führe deine Bücher auch anderswo; die deutschen Zuordnungen sind Entwürfe, bis Steuerberater sie geprüft haben.';

  @override
  String get previousYear => 'Voriges Jahr';

  @override
  String get price => 'Nettopreis';

  @override
  String get purchase => 'Eingangsrechnung';

  @override
  String get quantity => 'Menge';

  @override
  String get quarterly => 'Vierteljährlich';

  @override
  String get readDocument => 'Beleg einlesen';

  @override
  String get readStatement => 'Kontoauszug einlesen';

  @override
  String get reason => 'Grund';

  @override
  String get recorded => 'Erfasst';

  @override
  String get region => 'Bundesland';

  @override
  String get remove => 'Entfernen';

  @override
  String get reports => 'Meldungen';

  @override
  String get required => 'Pflichtfeld';

  @override
  String get result => 'Ergebnis';

  @override
  String get reversal => 'Storno';

  @override
  String get reverse => 'Stornieren';

  @override
  String get reversed => 'Storniert';

  @override
  String get reversedDone => 'Storniert.';

  @override
  String get review => 'Klärung';

  @override
  String get sale => 'Ausgangsrechnung';

  @override
  String get save => 'Buchen';

  @override
  String saved(String path) {
    return 'Gesichert: $path';
  }

  @override
  String get searchAccount => 'Nummer oder Name';

  @override
  String get seller => 'Absender';

  @override
  String get sellerHint => 'Deine Angaben auf Rechnungen, wie XRechnung sie verlangt.';

  @override
  String get service => 'Leistung';

  @override
  String get setUp => 'Einrichten';

  @override
  String get setUpText =>
      'spezado führt Bücher für eine Person – alles andere lässt sich später durch eine neue Konfiguration ändern.';

  @override
  String get setUpTitle => 'Bücher einrichten';

  @override
  String get settings => 'Sprache und Darstellung';

  @override
  String get simple => 'Bruttobetrag';

  @override
  String get smallBusinessLine => 'Ohne USt (§ 19 UStG)';

  @override
  String get start => 'Erster Tag';

  @override
  String get statementHint =>
      'camt.053 (XML), MT940 oder die CSV-Datei einer Bank; schon gelesene Umsätze werden übersprungen.';

  @override
  String get statements => 'Kontoauszüge';

  @override
  String get street => 'Straße';

  @override
  String get tax13b => 'Steuerschuldnerschaft des Leistungsempfängers (§ 13b)';

  @override
  String get taxCode => 'Steuerschlüssel';

  @override
  String get taxEuService => 'Sonstige Leistung in die EU (Reverse Charge)';

  @override
  String get taxExempt => 'Steuerfrei (§ 4 UStG)';

  @override
  String get taxExport => 'Ausfuhr';

  @override
  String get taxIgSupply => 'Innergemeinschaftliche Lieferung';

  @override
  String get taxNumber => 'Steuernummer';

  @override
  String get text => 'Text';

  @override
  String get themeAuto => 'Wie das System';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get to => 'Bis';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get unit => 'Einheit';

  @override
  String get unpair => 'Kopplung aufheben';

  @override
  String unreachable(String address) {
    return 'Unter $address antwortet nichts. Starte spezado mit `spezado serve`.';
  }

  @override
  String get validFrom => 'Gültig ab';

  @override
  String get vat => 'Umsatzsteuer';

  @override
  String get vatAccrual => 'Nach vereinbarten Entgelten (Soll)';

  @override
  String get vatBasis => 'Versteuerung';

  @override
  String get vatCash => 'Nach vereinnahmten Entgelten (Ist)';

  @override
  String get vatExtended => 'Dauerfristverlängerung (§ 46 UStDV)';

  @override
  String get vatId => 'USt-IdNr.';

  @override
  String get vatPeriod => 'Voranmeldungen';

  @override
  String get vatRegular => 'Regelbesteuerung';

  @override
  String get vatSmallBusiness => 'Kleinunternehmer (§ 19 UStG)';

  @override
  String get writeInvoice => 'Rechnung schreiben';

  @override
  String get yearly => 'Jährlich';

  @override
  String get yes => 'ja';
}
