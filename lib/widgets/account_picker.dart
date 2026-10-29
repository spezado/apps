// SPDX-License-Identifier: MIT
// Choosing an account by its number or a part of its name. Numbers match from the start; for names, those that start
// with what was typed come first, then accounts of income and expense, which are what one books on.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import 'common.dart';

/// The accounts that match what was typed, best first, at most `limit`.
List<AccountView> matchAccounts(List<AccountView> accounts, String typed, {int limit = 8}) {
  final text = typed.trim().toLowerCase();
  if (text.isEmpty) return const [];
  final numeric = RegExp(r'^\d+$').hasMatch(text);
  final found = accounts
      .where((a) => numeric ? (a.number ?? '').startsWith(text) : a.name.toLowerCase().contains(text))
      .toList();
  if (!numeric) {
    int rank(AccountView a) =>
        (a.name.toLowerCase().startsWith(text) ? 0 : 2) + (a.kind == 'income' || a.kind == 'expense' ? 0 : 1);
    mergeSort(found, compare: (a, b) => rank(a) - rank(b));
  }
  return found.take(limit).toList();
}

/// A stable sort, so that accounts of the same rank keep the order of the chart.
void mergeSort<T>(List<T> list, {required int Function(T, T) compare}) {
  final indexed = list.indexed.toList()
    ..sort((a, b) {
      final order = compare(a.$2, b.$2);
      return order != 0 ? order : a.$1 - b.$1;
    });
  list.setAll(0, indexed.map((e) => e.$2));
}

/// An account field: its value is the account's national number, or its identity when it has none. It shows the
/// value it was built with; a form that starts over gives it a new key.
class AccountPicker extends StatelessWidget {
  const AccountPicker({
    super.key,
    required this.accounts,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChosen,
  });

  final List<AccountView> accounts;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  /// Told the account taken from the list.
  final ValueChanged<AccountView>? onChosen;

  AccountView? get chosen => accounts.where((a) => a.number == value || a.id == value).firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<AccountView>(
      initialValue: TextEditingValue(text: value),
      optionsBuilder: (typed) => chosen != null && typed.text == value ? const [] : matchAccounts(accounts, typed.text),
      displayStringForOption: (account) => account.number ?? account.id,
      onSelected: (account) {
        onChanged(account.number ?? account.id);
        onChosen?.call(account);
      },
      fieldViewBuilder: (context, controller, focus, submit) {
        return TextFormField(
          controller: controller,
          focusNode: focus,
          decoration: InputDecoration(labelText: label, hintText: context.t.searchAccount, helperText: chosen?.name),
          onChanged: onChanged,
          onFieldSubmitted: (_) => submit(),
          validator: (_) => chosen == null ? context.t.chooseAccount : null,
        );
      },
      optionsViewBuilder: (context, select, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 320),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                for (final account in options)
                  Builder(
                    builder: (context) {
                      final active = AutocompleteHighlightedOption.of(context) == options.toList().indexOf(account);
                      return ListTile(
                        dense: true,
                        selected: active,
                        selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        leading: SizedBox(width: 56, child: Mono(account.number ?? '')),
                        title: Text(account.name),
                        onTap: () => select(account),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
