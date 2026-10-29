import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en')];

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @acceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept all proposals'**
  String get acceptAll;

  /// No description provided for @acceptedCount.
  ///
  /// In en, this message translates to:
  /// **'Booked: {count}'**
  String acceptedCount(int count);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Profit by'**
  String get accounting;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @addLine.
  ///
  /// In en, this message translates to:
  /// **'Add a line'**
  String get addLine;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address of spezado'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Shown by `spezado serve`; the link with #pair=… fills in the code too'**
  String get addressHint;

  /// No description provided for @addressInvalid.
  ///
  /// In en, this message translates to:
  /// **'An address like http://127.0.0.1:8048'**
  String get addressInvalid;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'An amount like 1234.50'**
  String get amountInvalid;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @asBefore.
  ///
  /// In en, this message translates to:
  /// **'As before'**
  String get asBefore;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @bookEntry.
  ///
  /// In en, this message translates to:
  /// **'Book by hand'**
  String get bookEntry;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked.'**
  String get booked;

  /// No description provided for @bookedBefore.
  ///
  /// In en, this message translates to:
  /// **'Booked before'**
  String get bookedBefore;

  /// No description provided for @buyerReference.
  ///
  /// In en, this message translates to:
  /// **'Buyer reference (Leitweg-ID)'**
  String get buyerReference;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @cashBasis.
  ///
  /// In en, this message translates to:
  /// **'Cash basis (EÜR)'**
  String get cashBasis;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart of accounts'**
  String get chart;

  /// No description provided for @chooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose an account from the list'**
  String get chooseAccount;

  /// No description provided for @chooseCustomer.
  ///
  /// In en, this message translates to:
  /// **'Choose a customer'**
  String get chooseCustomer;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing can be booked up to this day afterwards; corrections are booked later.'**
  String get closeHint;

  /// No description provided for @closeUpTo.
  ///
  /// In en, this message translates to:
  /// **'Close up to'**
  String get closeUpTo;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed up to'**
  String get closed;

  /// No description provided for @closedUntil.
  ///
  /// In en, this message translates to:
  /// **'Closed up to'**
  String get closedUntil;

  /// No description provided for @closing.
  ///
  /// In en, this message translates to:
  /// **'Closing'**
  String get closing;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Pairing code'**
  String get code;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get contact;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country (ISO code)'**
  String get country;

  /// No description provided for @countryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Two letters: DE, AT, FR …'**
  String get countryInvalid;

  /// No description provided for @csv.
  ///
  /// In en, this message translates to:
  /// **'Save as CSV'**
  String get csv;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Date of delivery'**
  String get deliveryDate;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Name of this device'**
  String get deviceName;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @documentHint.
  ///
  /// In en, this message translates to:
  /// **'An e-invoice (XRechnung, ZUGFeRD) comes with a booking proposal; a PDF or a photo is filed to book by hand.'**
  String get documentHint;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @doubleEntry.
  ///
  /// In en, this message translates to:
  /// **'Double entry (balance sheet)'**
  String get doubleEntry;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft – not reviewed by tax advisers yet'**
  String get draft;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get due;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @enterOpening.
  ///
  /// In en, this message translates to:
  /// **'Enter opening balances'**
  String get enterOpening;

  /// No description provided for @exemptionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason of the exemption'**
  String get exemptionReason;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @exportZip.
  ///
  /// In en, this message translates to:
  /// **'Save ZIP'**
  String get exportZip;

  /// No description provided for @fetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch from the bank'**
  String get fetch;

  /// No description provided for @fileAndBook.
  ///
  /// In en, this message translates to:
  /// **'File and book'**
  String get fileAndBook;

  /// No description provided for @fileOnly.
  ///
  /// In en, this message translates to:
  /// **'File only'**
  String get fileOnly;

  /// No description provided for @filed.
  ///
  /// In en, this message translates to:
  /// **'Filed.'**
  String get filed;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fromInvoice.
  ///
  /// In en, this message translates to:
  /// **'Pays invoice'**
  String get fromInvoice;

  /// No description provided for @gobd.
  ///
  /// In en, this message translates to:
  /// **'Data transfer for auditors (GoBD)'**
  String get gobd;

  /// No description provided for @gobdHint.
  ///
  /// In en, this message translates to:
  /// **'The bookings, accounts and documents of a period as a ZIP file (Z3).'**
  String get gobdHint;

  /// No description provided for @gross.
  ///
  /// In en, this message translates to:
  /// **'Gross amount'**
  String get gross;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @ibanForCsv.
  ///
  /// In en, this message translates to:
  /// **'IBAN – only for a bank\'s CSV file'**
  String get ibanForCsv;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'New entries: {entries} · known before: {known}'**
  String imported(int entries, int known);

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @invoiceFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get invoiceFile;

  /// No description provided for @invoiceWritten.
  ///
  /// In en, this message translates to:
  /// **'Invoice written'**
  String get invoiceWritten;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @issues.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get issues;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @lines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get lines;

  /// No description provided for @linesHint.
  ///
  /// In en, this message translates to:
  /// **'Debit positive, credit negative; the lines must add up to zero.'**
  String get linesHint;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get newInvoice;

  /// No description provided for @nextVatReturn.
  ///
  /// In en, this message translates to:
  /// **'Next advance VAT return'**
  String get nextVatReturn;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @noBalances.
  ///
  /// In en, this message translates to:
  /// **'No account has a balance this year.'**
  String get noBalances;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents yet.'**
  String get noDocuments;

  /// No description provided for @noOpenEntries.
  ///
  /// In en, this message translates to:
  /// **'Every entry is booked.'**
  String get noOpenEntries;

  /// No description provided for @noOpening.
  ///
  /// In en, this message translates to:
  /// **'No opening balances booked.'**
  String get noOpening;

  /// No description provided for @noProposal.
  ///
  /// In en, this message translates to:
  /// **'No proposal – file it and book it by hand.'**
  String get noProposal;

  /// No description provided for @noRegion.
  ///
  /// In en, this message translates to:
  /// **'No state'**
  String get noRegion;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports for this year.'**
  String get noReports;

  /// No description provided for @noTax.
  ///
  /// In en, this message translates to:
  /// **'No tax code'**
  String get noTax;

  /// No description provided for @noVatReturns.
  ///
  /// In en, this message translates to:
  /// **'No advance VAT returns.'**
  String get noVatReturns;

  /// No description provided for @notAnInvoice.
  ///
  /// In en, this message translates to:
  /// **'Not read as an e-invoice'**
  String get notAnInvoice;

  /// No description provided for @notBooked.
  ///
  /// In en, this message translates to:
  /// **'not booked'**
  String get notBooked;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @nothingBooked.
  ///
  /// In en, this message translates to:
  /// **'Nothing booked yet.'**
  String get nothingBooked;

  /// No description provided for @nothingClosed.
  ///
  /// In en, this message translates to:
  /// **'nothing'**
  String get nothingClosed;

  /// No description provided for @nothingToReview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review.'**
  String get nothingToReview;

  /// No description provided for @numberInvalid.
  ///
  /// In en, this message translates to:
  /// **'A whole number'**
  String get numberInvalid;

  /// No description provided for @numberPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix of invoice numbers'**
  String get numberPrefix;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'spezado does not answer at {address}. Is `spezado serve` running?'**
  String offline(String address);

  /// No description provided for @openEntries.
  ///
  /// In en, this message translates to:
  /// **'Open entries'**
  String get openEntries;

  /// No description provided for @openingBalances.
  ///
  /// In en, this message translates to:
  /// **'Opening balances'**
  String get openingBalances;

  /// No description provided for @openingHint.
  ///
  /// In en, this message translates to:
  /// **'What the accounts held on the first day of the books – positive for assets, negative for debts.'**
  String get openingHint;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Save the original'**
  String get original;

  /// No description provided for @otherLanguage.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get otherLanguage;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pair;

  /// No description provided for @pairAgain.
  ///
  /// In en, this message translates to:
  /// **'Pair again'**
  String get pairAgain;

  /// No description provided for @pairText.
  ///
  /// In en, this message translates to:
  /// **'Start spezado on this device with `spezado serve` and enter the code it shows. This app keeps its own token, which spezado can revoke.'**
  String get pairText;

  /// No description provided for @pairTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair with spezado'**
  String get pairTitle;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get payment;

  /// No description provided for @paymentDays.
  ///
  /// In en, this message translates to:
  /// **'Days to pay'**
  String get paymentDays;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @postcode.
  ///
  /// In en, this message translates to:
  /// **'Postcode'**
  String get postcode;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview: spezado 0.1 is for trying out. Keep your books elsewhere as well; the German mappings are drafts until tax advisers have reviewed them.'**
  String get preview;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Net price'**
  String get price;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @readDocument.
  ///
  /// In en, this message translates to:
  /// **'Read a document'**
  String get readDocument;

  /// No description provided for @readStatement.
  ///
  /// In en, this message translates to:
  /// **'Read a statement'**
  String get readStatement;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get region;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @reversal.
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get reversal;

  /// No description provided for @reverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get reverse;

  /// No description provided for @reversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get reversed;

  /// No description provided for @reversedDone.
  ///
  /// In en, this message translates to:
  /// **'Reversed.'**
  String get reversedDone;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String saved(String path);

  /// No description provided for @searchAccount.
  ///
  /// In en, this message translates to:
  /// **'Number or name'**
  String get searchAccount;

  /// No description provided for @seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get seller;

  /// No description provided for @sellerHint.
  ///
  /// In en, this message translates to:
  /// **'Your details on invoices, as XRechnung asks for them.'**
  String get sellerHint;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @setUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get setUp;

  /// No description provided for @setUpText.
  ///
  /// In en, this message translates to:
  /// **'spezado keeps books for a person – everything else can be changed later by a new configuration.'**
  String get setUpText;

  /// No description provided for @setUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the books'**
  String get setUpTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Language and appearance'**
  String get settings;

  /// No description provided for @simple.
  ///
  /// In en, this message translates to:
  /// **'Gross amount'**
  String get simple;

  /// No description provided for @smallBusinessLine.
  ///
  /// In en, this message translates to:
  /// **'No VAT (§ 19 UStG)'**
  String get smallBusinessLine;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get start;

  /// No description provided for @statementHint.
  ///
  /// In en, this message translates to:
  /// **'camt.053 (XML), MT940 or a bank\'s CSV file; entries read before are skipped.'**
  String get statementHint;

  /// No description provided for @statements.
  ///
  /// In en, this message translates to:
  /// **'Statements'**
  String get statements;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @tax13b.
  ///
  /// In en, this message translates to:
  /// **'Reverse charge (§ 13b)'**
  String get tax13b;

  /// No description provided for @taxCode.
  ///
  /// In en, this message translates to:
  /// **'Tax code'**
  String get taxCode;

  /// No description provided for @taxEuService.
  ///
  /// In en, this message translates to:
  /// **'Service to the EU (reverse charge)'**
  String get taxEuService;

  /// No description provided for @taxExempt.
  ///
  /// In en, this message translates to:
  /// **'Exempt (§ 4 UStG)'**
  String get taxExempt;

  /// No description provided for @taxExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get taxExport;

  /// No description provided for @taxIgSupply.
  ///
  /// In en, this message translates to:
  /// **'Intra-community supply'**
  String get taxIgSupply;

  /// No description provided for @taxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax number'**
  String get taxNumber;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Like the system'**
  String get themeAuto;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unpair.
  ///
  /// In en, this message translates to:
  /// **'Unpair this device'**
  String get unpair;

  /// No description provided for @unreachable.
  ///
  /// In en, this message translates to:
  /// **'Nothing answers at {address}. Start spezado with `spezado serve`.'**
  String unreachable(String address);

  /// No description provided for @validFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get validFrom;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vat;

  /// No description provided for @vatAccrual.
  ///
  /// In en, this message translates to:
  /// **'When invoiced (Soll)'**
  String get vatAccrual;

  /// No description provided for @vatBasis.
  ///
  /// In en, this message translates to:
  /// **'VAT due'**
  String get vatBasis;

  /// No description provided for @vatCash.
  ///
  /// In en, this message translates to:
  /// **'When paid (Ist)'**
  String get vatCash;

  /// No description provided for @vatExtended.
  ///
  /// In en, this message translates to:
  /// **'Permanent extension (§ 46 UStDV)'**
  String get vatExtended;

  /// No description provided for @vatId.
  ///
  /// In en, this message translates to:
  /// **'VAT ID'**
  String get vatId;

  /// No description provided for @vatPeriod.
  ///
  /// In en, this message translates to:
  /// **'Advance returns'**
  String get vatPeriod;

  /// No description provided for @vatRegular.
  ///
  /// In en, this message translates to:
  /// **'Liable to VAT'**
  String get vatRegular;

  /// No description provided for @vatSmallBusiness.
  ///
  /// In en, this message translates to:
  /// **'Small business (§ 19 UStG)'**
  String get vatSmallBusiness;

  /// No description provided for @writeInvoice.
  ///
  /// In en, this message translates to:
  /// **'Write the invoice'**
  String get writeInvoice;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
