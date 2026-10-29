// SPDX-License-Identifier: MIT
// What every page uses: reading from the API again when the books change, a frame, panels, amounts, dates, and
// telling people what happened.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api.g.dart';
import '../api/transport.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../app/theme.dart';
import '../l10n/app_localizations.dart';

extension Texts on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}

/// Reads from the API and shows what it read; reads again when the books, the year, the language or the books'
/// content change, keeping what it showed until the new answer is there.
class Loaded<T> extends StatefulWidget {
  const Loaded({super.key, required this.load, required this.builder, this.reload = const []});

  final Future<T> Function(SpezadoApi api, String books, AppState state) load;
  final Widget Function(BuildContext context, T value) builder;

  /// More that makes it read again.
  final List<Object?> reload;

  @override
  State<Loaded<T>> createState() => _LoadedState<T>();
}

class _LoadedState<T> extends State<Loaded<T>> {
  List<Object?>? _key;
  T? _value;
  bool _has = false;
  String? _failure;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _read();
  }

  @override
  void didUpdateWidget(Loaded<T> old) {
    super.didUpdateWidget(old);
    _read();
  }

  void _read() {
    final state = AppScope.of(context);
    final api = state.api;
    final books = state.books;
    if (api == null || books == null) return;
    final key = [books, state.year, state.lang, state.version, ...widget.reload];
    if (_key != null && _same(_key!, key)) return;
    _key = key;
    widget
        .load(api, books, state)
        .then(
          (value) {
            if (!mounted || !_same(_key!, key)) return;
            setState(() {
              _value = value;
              _has = true;
              _failure = null;
            });
          },
          onError: (Object error) {
            if (!mounted || !_same(_key!, key)) return;
            setState(() => _failure = '$error');
          },
        );
  }

  static bool _same(List<Object?> a, List<Object?> b) =>
      a.length == b.length && Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);

  @override
  Widget build(BuildContext context) {
    if (_failure case final failure?) return Failure(failure);
    if (!_has) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.builder(context, _value as T);
  }
}

/// A page: a title and its content, scrolling, no wider than one can read.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.title, required this.children, this.actions = const []});

  final String title;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  ...actions,
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A heading within a page.
class Heading extends StatelessWidget {
  const Heading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}

class Muted extends StatelessWidget {
  const Muted(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(color: Brand.of(context).muted));
}

class Failure extends StatelessWidget {
  const Failure(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: TextStyle(color: Brand.of(context).error)),
  );
}

/// An amount as people of the language write it, its figures aligned.
class Money extends StatelessWidget {
  const Money(this.value, {super.key, this.style});

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    amount(value, AppScope.of(context).lang),
    textAlign: TextAlign.right,
    style: (style ?? const TextStyle()).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
  );
}

/// An account's number, in the monospaced font.
class Mono extends StatelessWidget {
  const Mono(this.text, {super.key, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Menlo',
      fontFamilyFallback: const ['Consolas', 'monospace'],
      fontSize: 13,
      color: muted ? Brand.of(context).muted : null,
    ),
  );
}

/// The lines of a booking: account, name, amount, tax code.
class Postings extends StatelessWidget {
  const Postings(this.postings, {super.key});

  final List<PostingView> postings;

  @override
  Widget build(BuildContext context) => Table(
    columnWidths: const {
      0: IntrinsicColumnWidth(),
      1: FlexColumnWidth(),
      2: IntrinsicColumnWidth(),
      3: IntrinsicColumnWidth(),
    },
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: [
      for (final posting in postings)
        TableRow(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(0, 6, 16, 6), child: Mono(posting.number ?? '')),
            Text(posting.name),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Money(posting.amount.value)),
            Mono(posting.tax ?? '', muted: true),
          ],
        ),
    ],
  );
}

/// Runs something that writes to spezado and tells what happened; returns whether it worked.
Future<bool> act(BuildContext context, Future<void> Function() action, {String? done}) async {
  final messenger = ScaffoldMessenger.of(context);
  final brand = Brand.of(context);
  try {
    await action();
    if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
    return true;
  } on ApiException catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.message), backgroundColor: brand.error));
    return false;
  }
}

/// Tells something that is wrong before anything is sent.
void complain(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: Brand.of(context).error));

/// A day, typed or picked; its value as the API writes it.
class DateField extends StatefulWidget {
  const DateField({super.key, required this.label, required this.value, required this.onChanged, this.required = true});

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool required;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(DateField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final initial = DateTime.tryParse(_controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) widget.onChanged(isoDate(picked));
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _controller,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: 'YYYY-MM-DD',
      suffixIcon: IconButton(icon: const Icon(Icons.calendar_today_outlined, size: 18), onPressed: _pick),
    ),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))],
    onChanged: widget.onChanged,
    validator: (value) {
      if ((value ?? '').isEmpty) return widget.required ? context.t.required : null;
      return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value!) && DateTime.tryParse(value) != null ? null : 'YYYY-MM-DD';
    },
  );
}

/// A text field for a form, with its label; empty is wrong unless `required` is false.
class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.label,
    required this.controller,
    this.required = true,
    this.number = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final bool number;
  final String? Function(String value)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: number ? const TextInputType.numberWithOptions(decimal: true, signed: true) : null,
    validator: (value) {
      if ((value ?? '').trim().isEmpty) return required ? context.t.required : null;
      return validator?.call(value!.trim());
    },
  );
}

/// A choice among values, each with what people read.
class Choice<T> extends StatelessWidget {
  const Choice({super.key, required this.label, required this.value, required this.options, required this.onChanged});

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: options.containsKey(value) ? value : null,
    key: ValueKey(value),
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final MapEntry(:key, :value) in options.entries)
        DropdownMenuItem(
          value: key,
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (chosen) {
      if (chosen is T) onChanged(chosen);
    },
  );
}

/// Fields side by side where there is room, one below the other where there is not.
class Fields extends StatelessWidget {
  const Fields({super.key, required this.children, this.width = 260});

  final List<Widget> children;
  final double width;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = (constraints.maxWidth / width).floor().clamp(1, 4);
      final each = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [for (final child in children) SizedBox(width: each, child: child)],
      );
    },
  );
}

/// A form's column: fields with room between them, no wider than one fills in.
class FormColumn extends StatelessWidget {
  const FormColumn({super.key, required this.children, this.maxWidth = 640});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, child) in children.indexed) ...[if (i > 0) const SizedBox(height: 14), child],
        ],
      ),
    ),
  );
}

/// Buttons in a row, wrapping where there is no room.
class ButtonRow extends StatelessWidget {
  const ButtonRow(this.children, {super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: children);
}
