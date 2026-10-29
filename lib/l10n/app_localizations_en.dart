// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accept => 'Accept';

  @override
  String get acceptAll => 'Accept all proposals';

  @override
  String acceptedCount(int count) {
    return 'Booked: $count';
  }

  @override
  String get account => 'Account';

  @override
  String get accounting => 'Profit by';

  @override
  String get accounts => 'Accounts';

  @override
  String get addLine => 'Add a line';

  @override
  String get address => 'Address of spezado';

  @override
  String get addressHint => 'Shown by `spezado serve`; the link with #pair=… fills in the code too';

  @override
  String get addressInvalid => 'An address like http://127.0.0.1:8048';

  @override
  String get amount => 'Amount';

  @override
  String get amountInvalid => 'An amount like 1234.50';

  @override
  String get apply => 'Apply';

  @override
  String get asBefore => 'As before';

  @override
  String get back => 'Back';

  @override
  String get balance => 'Balance';

  @override
  String get bank => 'Bank';

  @override
  String get book => 'Book';

  @override
  String get bookEntry => 'Book by hand';

  @override
  String get booked => 'Booked.';

  @override
  String get bookedBefore => 'Booked before';

  @override
  String get buyerReference => 'Buyer reference (Leitweg-ID)';

  @override
  String get cancel => 'Cancel';

  @override
  String get cash => 'Cash';

  @override
  String get cashBasis => 'Cash basis (EÜR)';

  @override
  String get change => 'Change';

  @override
  String get chart => 'Chart of accounts';

  @override
  String get chooseAccount => 'Choose an account from the list';

  @override
  String get chooseCustomer => 'Choose a customer';

  @override
  String get city => 'City';

  @override
  String get close => 'Close';

  @override
  String get closeHint => 'Nothing can be booked up to this day afterwards; corrections are booked later.';

  @override
  String get closeUpTo => 'Close up to';

  @override
  String get closed => 'Closed up to';

  @override
  String get closedUntil => 'Closed up to';

  @override
  String get closing => 'Closing';

  @override
  String get code => 'Pairing code';

  @override
  String get contact => 'Contact person';

  @override
  String get country => 'Country (ISO code)';

  @override
  String get countryInvalid => 'Two letters: DE, AT, FR …';

  @override
  String get csv => 'Save as CSV';

  @override
  String get customer => 'Customer';

  @override
  String get date => 'Date';

  @override
  String get days => 'Days';

  @override
  String get deliveryDate => 'Date of delivery';

  @override
  String get deviceName => 'Name of this device';

  @override
  String get direction => 'Direction';

  @override
  String get documentHint =>
      'An e-invoice (XRechnung, ZUGFeRD) comes with a booking proposal; a PDF or a photo is filed to book by hand.';

  @override
  String get documents => 'Documents';

  @override
  String get doubleEntry => 'Double entry (balance sheet)';

  @override
  String get draft => 'Draft – not reviewed by tax advisers yet';

  @override
  String get due => 'due';

  @override
  String get email => 'E-mail';

  @override
  String get enterOpening => 'Enter opening balances';

  @override
  String get exemptionReason => 'Reason of the exemption';

  @override
  String get expenses => 'Expenses';

  @override
  String get exportZip => 'Save ZIP';

  @override
  String get fetch => 'Fetch from the bank';

  @override
  String get fileAndBook => 'File and book';

  @override
  String get fileOnly => 'File only';

  @override
  String get filed => 'Filed.';

  @override
  String get from => 'From';

  @override
  String get fromInvoice => 'Pays invoice';

  @override
  String get gobd => 'Data transfer for auditors (GoBD)';

  @override
  String get gobdHint => 'The bookings, accounts and documents of a period as a ZIP file (Z3).';

  @override
  String get gross => 'Gross amount';

  @override
  String get hours => 'Hours';

  @override
  String get ibanForCsv => 'IBAN – only for a bank\'s CSV file';

  @override
  String imported(int entries, int known) {
    return 'New entries: $entries · known before: $known';
  }

  @override
  String get income => 'Income';

  @override
  String get invoiceFile => 'File';

  @override
  String get invoiceWritten => 'Invoice written';

  @override
  String get invoices => 'Invoices';

  @override
  String get issues => 'To review';

  @override
  String get journal => 'Journal';

  @override
  String get keep => 'Keep';

  @override
  String get ledger => 'Ledger';

  @override
  String get lines => 'Lines';

  @override
  String get linesHint => 'Debit positive, credit negative; the lines must add up to zero.';

  @override
  String get monthly => 'Monthly';

  @override
  String get name => 'Name';

  @override
  String get newCustomer => 'New customer';

  @override
  String get newInvoice => 'New invoice';

  @override
  String get nextVatReturn => 'Next advance VAT return';

  @override
  String get nextYear => 'Next year';

  @override
  String get no => 'no';

  @override
  String get noBalances => 'No account has a balance this year.';

  @override
  String get noDocuments => 'No documents yet.';

  @override
  String get noOpenEntries => 'Every entry is booked.';

  @override
  String get noOpening => 'No opening balances booked.';

  @override
  String get noProposal => 'No proposal – file it and book it by hand.';

  @override
  String get noRegion => 'No state';

  @override
  String get noReports => 'No reports for this year.';

  @override
  String get noTax => 'No tax code';

  @override
  String get noVatReturns => 'No advance VAT returns.';

  @override
  String get notAnInvoice => 'Not read as an e-invoice';

  @override
  String get notBooked => 'not booked';

  @override
  String get note => 'Note';

  @override
  String get nothingBooked => 'Nothing booked yet.';

  @override
  String get nothingClosed => 'nothing';

  @override
  String get nothingToReview => 'Nothing to review.';

  @override
  String get numberInvalid => 'A whole number';

  @override
  String get numberPrefix => 'Prefix of invoice numbers';

  @override
  String offline(String address) {
    return 'spezado does not answer at $address. Is `spezado serve` running?';
  }

  @override
  String get openEntries => 'Open entries';

  @override
  String get openingBalances => 'Opening balances';

  @override
  String get openingHint =>
      'What the accounts held on the first day of the books – positive for assets, negative for debts.';

  @override
  String get original => 'Save the original';

  @override
  String get otherLanguage => 'Deutsch';

  @override
  String get overview => 'Overview';

  @override
  String get pair => 'Pair';

  @override
  String get pairAgain => 'Pair again';

  @override
  String get pairText =>
      'Start spezado on this device with `spezado serve` and enter the code it shows. This app keeps its own token, which spezado can revoke.';

  @override
  String get pairTitle => 'Pair with spezado';

  @override
  String get payment => 'Paid by';

  @override
  String get paymentDays => 'Days to pay';

  @override
  String get phone => 'Phone';

  @override
  String get pieces => 'Pieces';

  @override
  String get postcode => 'Postcode';

  @override
  String get preview =>
      'Preview: spezado 0.1 is for trying out. Keep your books elsewhere as well; the German mappings are drafts until tax advisers have reviewed them.';

  @override
  String get previousYear => 'Previous year';

  @override
  String get price => 'Net price';

  @override
  String get purchase => 'Purchase';

  @override
  String get quantity => 'Quantity';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get readDocument => 'Read a document';

  @override
  String get readStatement => 'Read a statement';

  @override
  String get reason => 'Reason';

  @override
  String get recorded => 'Recorded';

  @override
  String get region => 'State';

  @override
  String get remove => 'Remove';

  @override
  String get reports => 'Reports';

  @override
  String get required => 'Required';

  @override
  String get result => 'Result';

  @override
  String get reversal => 'Reversal';

  @override
  String get reverse => 'Reverse';

  @override
  String get reversed => 'Reversed';

  @override
  String get reversedDone => 'Reversed.';

  @override
  String get review => 'Review';

  @override
  String get sale => 'Sale';

  @override
  String get save => 'Book';

  @override
  String saved(String path) {
    return 'Saved: $path';
  }

  @override
  String get searchAccount => 'Number or name';

  @override
  String get seller => 'Seller';

  @override
  String get sellerHint => 'Your details on invoices, as XRechnung asks for them.';

  @override
  String get service => 'Service';

  @override
  String get setUp => 'Set up';

  @override
  String get setUpText =>
      'spezado keeps books for a person – everything else can be changed later by a new configuration.';

  @override
  String get setUpTitle => 'Set up the books';

  @override
  String get settings => 'Language and appearance';

  @override
  String get simple => 'Gross amount';

  @override
  String get smallBusinessLine => 'No VAT (§ 19 UStG)';

  @override
  String get start => 'First day';

  @override
  String get statementHint => 'camt.053 (XML), MT940 or a bank\'s CSV file; entries read before are skipped.';

  @override
  String get statements => 'Statements';

  @override
  String get street => 'Street';

  @override
  String get tax13b => 'Reverse charge (§ 13b)';

  @override
  String get taxCode => 'Tax code';

  @override
  String get taxEuService => 'Service to the EU (reverse charge)';

  @override
  String get taxExempt => 'Exempt (§ 4 UStG)';

  @override
  String get taxExport => 'Export';

  @override
  String get taxIgSupply => 'Intra-community supply';

  @override
  String get taxNumber => 'Tax number';

  @override
  String get text => 'Text';

  @override
  String get themeAuto => 'Like the system';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get to => 'To';

  @override
  String get tryAgain => 'Try again';

  @override
  String get unit => 'Unit';

  @override
  String get unpair => 'Unpair this device';

  @override
  String unreachable(String address) {
    return 'Nothing answers at $address. Start spezado with `spezado serve`.';
  }

  @override
  String get validFrom => 'Valid from';

  @override
  String get vat => 'VAT';

  @override
  String get vatAccrual => 'When invoiced (Soll)';

  @override
  String get vatBasis => 'VAT due';

  @override
  String get vatCash => 'When paid (Ist)';

  @override
  String get vatExtended => 'Permanent extension (§ 46 UStDV)';

  @override
  String get vatId => 'VAT ID';

  @override
  String get vatPeriod => 'Advance returns';

  @override
  String get vatRegular => 'Liable to VAT';

  @override
  String get vatSmallBusiness => 'Small business (§ 19 UStG)';

  @override
  String get writeInvoice => 'Write the invoice';

  @override
  String get yearly => 'Yearly';

  @override
  String get yes => 'yes';

  @override
  String get welcomeTitle => 'Welcome to spezado';

  @override
  String get welcomeText => 'The app keeps your books with spezado, which runs on this device – nothing leaves it.';

  @override
  String get installTitle => 'Install spezado on this device';

  @override
  String installText(String version) {
    return 'Downloads spezado $version from its release on GitHub, checks it and starts it with an icon in the menu bar or the system tray. It keeps running when you close the app.';
  }

  @override
  String installTextNoTray(String version) {
    return 'Downloads spezado $version from its release on GitHub, checks it and starts it in the background. It keeps running when you close the app.';
  }

  @override
  String get startAtLogin => 'Start spezado when I log in';

  @override
  String get installAndStart => 'Install and start';

  @override
  String get connectInstead => 'spezado runs already – connect to it';

  @override
  String get alreadyRunning => 'spezado runs already on this device: enter the code it shows.';

  @override
  String installFailed(String reason) {
    return 'spezado could not be installed: $reason';
  }
}
