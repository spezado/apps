// SPDX-License-Identifier: MIT
// The frame: pairing first, then setting up books, then the pages with their navigation – read again whenever the
// books change.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import '../pages/accounts.dart';
import '../pages/bank.dart';
import '../pages/book.dart';
import '../pages/closing.dart';
import '../pages/documents.dart';
import '../pages/invoices.dart';
import '../pages/journal.dart';
import '../pages/overview.dart';
import '../pages/pair.dart';
import '../pages/reports.dart';
import '../pages/review.dart';
import '../pages/set_up.dart';
import '../widgets/common.dart';
import 'state.dart';
import 'theme.dart';

class SpezadoApp extends StatelessWidget {
  const SpezadoApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'spezado',
          debugShowCheckedModeBanner: false,
          theme: theme(Brightness.light),
          darkTheme: theme(Brightness.dark),
          themeMode: state.theme,
          locale: Locale(state.lang),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _Home(),
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.paired) return const PairPage();
    if (state.allBooks == null) {
      return Scaffold(
        body: Center(
          child: state.failure == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Failure(context.t.offline(state.address.toString())),
                    const SizedBox(height: 12),
                    ButtonRow([
                      FilledButton(onPressed: state.loadBooks, child: Text(context.t.tryAgain)),
                      OutlinedButton(onPressed: state.unpair, child: Text(context.t.pairAgain)),
                    ]),
                  ],
                ),
        ),
      );
    }
    if (state.allBooks!.isEmpty) return const SetUpPage();
    return const _Shell();
  }
}

/// The pages in the navigation, with their icons; booking is the button above them.
const _pages = [
  (Screen.overview, Icons.dashboard_outlined),
  (Screen.journal, Icons.list_alt_outlined),
  (Screen.bank, Icons.account_balance_outlined),
  (Screen.documents, Icons.receipt_long_outlined),
  (Screen.invoices, Icons.request_quote_outlined),
  (Screen.accounts, Icons.account_tree_outlined),
  (Screen.reports, Icons.summarize_outlined),
  (Screen.review, Icons.fact_check_outlined),
  (Screen.closing, Icons.lock_clock_outlined),
];

String pageName(BuildContext context, Screen page) {
  final t = context.t;
  return switch (page) {
    Screen.overview => t.overview,
    Screen.journal => t.journal,
    Screen.bank => t.bank,
    Screen.documents => t.documents,
    Screen.invoices => t.invoices,
    Screen.accounts => t.accounts,
    Screen.reports => t.reports,
    Screen.review => t.review,
    Screen.closing => t.closing,
    Screen.book => t.book,
  };
}

class _Shell extends StatelessWidget {
  const _Shell();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final page = switch (state.page) {
      Screen.overview => const OverviewPage(),
      Screen.journal => const JournalPage(),
      Screen.bank => const BankPage(),
      Screen.documents => const DocumentsPage(),
      Screen.invoices => const InvoicesPage(),
      Screen.accounts => const AccountsPage(),
      Screen.reports => const ReportsPage(),
      Screen.review => const ReviewPage(),
      Screen.closing => const ClosingPage(),
      Screen.book => const BookPage(),
    };
    final content = Column(
      children: [
        if (state.failure case final failure?) Failure(failure),
        Expanded(
          child: KeyedSubtree(key: ValueKey(state.page), child: page),
        ),
      ],
    );
    if (!wide) {
      return Scaffold(
        appBar: AppBar(title: Text(pageName(context, state.page)), actions: const [_Tools(compact: true)]),
        drawer: Drawer(
          child: SafeArea(child: _Navigation(onGone: () => Navigator.of(context).pop())),
        ),
        floatingActionButton: state.page == Screen.book
            ? null
            : FloatingActionButton(
                onPressed: () => state.go(Screen.book),
                tooltip: context.t.book,
                child: const Icon(Icons.add),
              ),
        body: content,
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 232,
            child: Material(color: Brand.of(context).surface, child: const _Navigation()),
          ),
          VerticalDivider(width: 1, color: Brand.of(context).line),
          Expanded(
            child: Column(
              children: [
                Material(
                  color: Brand.of(context).surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.current?.ownerName ?? '',
                            style: TextStyle(fontFamily: serif, fontSize: 17, color: Brand.of(context).muted),
                          ),
                        ),
                        const _Tools(),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: Brand.of(context).line),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({this.onGone});

  final VoidCallback? onGone;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final brand = Brand.of(context);
    void go(Screen page) {
      state.go(page);
      onGone?.call();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              dark ? 'assets/brand/spezado-lockup-on-dark.svg' : 'assets/brand/spezado-lockup-on-light.svg',
              height: 36,
              semanticsLabel: 'spezado',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: FilledButton.icon(
            onPressed: () => go(Screen.book),
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.t.book),
          ),
        ),
        for (final (page, icon) in _pages)
          ListTile(
            dense: true,
            selected: state.page == page,
            selectedColor: brand.accent,
            selectedTileColor: brand.accent.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            leading: Icon(icon, size: 20),
            title: Text(pageName(context, page), style: const TextStyle(fontSize: 15)),
            onTap: () => go(page),
          ),
      ],
    );
  }
}

/// The year, the language and the appearance.
class _Tools extends StatelessWidget {
  const _Tools({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = context.t;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: t.previousYear,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => state.setYear(state.year - 1),
        ),
        Text('${state.year}', style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()], fontSize: 16)),
        IconButton(
          tooltip: t.nextYear,
          icon: const Icon(Icons.chevron_right),
          onPressed: () => state.setYear(state.year + 1),
        ),
        if (!compact) const SizedBox(width: 8),
        PopupMenuButton<void>(
          tooltip: t.settings,
          icon: const Icon(Icons.tune),
          itemBuilder: (context) => [
            PopupMenuItem(onTap: () => state.setLang(state.lang == 'de' ? 'en' : 'de'), child: Text(t.otherLanguage)),
            const PopupMenuDivider(),
            for (final (mode, name) in [
              (ThemeMode.system, t.themeAuto),
              (ThemeMode.light, t.themeLight),
              (ThemeMode.dark, t.themeDark),
            ])
              CheckedPopupMenuItem(checked: state.theme == mode, onTap: () => state.setTheme(mode), child: Text(name)),
            const PopupMenuDivider(),
            PopupMenuItem(onTap: state.unpair, child: Text(t.unpair)),
          ],
        ),
      ],
    );
  }
}
