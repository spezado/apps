// SPDX-License-Identifier: MIT
// Invoices: the seller's details, the customers, and a new invoice written as XRechnung or ZUGFeRD – recorded as a
// document, booked when paid on a cash basis, when issued with double entry.

import 'package:flutter/material.dart';

import '../api/api.g.dart';
import '../app/format.dart';
import '../app/state.dart';
import '../widgets/common.dart';
import '../widgets/files.dart';

/// Text fields by the name of what they hold.
class _Controllers {
  _Controllers(Map<String, String> values) : fields = values.map((k, v) => MapEntry(k, TextEditingController(text: v)));

  final Map<String, TextEditingController> fields;

  TextEditingController operator [](String name) => fields[name]!;

  String text(String name) => fields[name]!.text.trim();

  String? optional(String name) => text(name).isEmpty ? null : text(name);

  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
  }
}

class _Line {
  final name = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final price = TextEditingController();
  String unit = 'HUR';
  String tax = 'de-out-19';

  void dispose() {
    name.dispose();
    quantity.dispose();
    price.dispose();
  }
}

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  _Controllers? _profile;
  _Controllers? _customer;
  int _reload = 0;
  Issued? _issued;

  @override
  void dispose() {
    _profile?.dispose();
    _customer?.dispose();
    super.dispose();
  }

  void _editProfile(InvoiceProfile? profile) => setState(() {
    _profile?.dispose();
    _profile = _Controllers({
      'name': profile?.name ?? '',
      'street': profile?.street ?? '',
      'postcode': profile?.postcode ?? '',
      'city': profile?.city ?? '',
      'country': profile?.country ?? 'DE',
      'vat_id': profile?.vatId ?? '',
      'tax_number': profile?.taxNumber ?? '',
      'contact': profile?.contact ?? '',
      'phone': profile?.phone ?? '',
      'email': profile?.email ?? '',
      'iban': profile?.iban ?? '',
      'payment_days': '${profile?.paymentDays ?? 14}',
      'prefix': profile?.prefix ?? 'RE-',
    });
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return PageFrame(
      title: t.invoices,
      children: [
        Loaded<(InvoiceProfile?, List<Customer>)>(
          reload: [_reload],
          load: (api, books, state) async => (await api.profile(books: books), await api.customers(books: books)),
          builder: (context, loaded) {
            final (profile, customers) = loaded;
            if (profile == null && _profile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _profile == null) _editProfile(null);
              });
            }
            if (_profile case final form?) {
              return _ProfileForm(
                form: form,
                canCancel: profile != null,
                onDone: () => setState(() {
                  _profile?.dispose();
                  _profile = null;
                  _reload++;
                }),
              );
            }
            if (profile == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    Muted('${t.seller}: ${profile.name}, ${profile.city}'),
                    OutlinedButton(onPressed: () => _editProfile(profile), child: Text(t.change)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_customer case final form?)
                  _CustomerForm(
                    form: form,
                    onDone: (saved) => setState(() {
                      _customer?.dispose();
                      _customer = null;
                      _reload++;
                    }),
                  )
                else
                  _InvoiceForm(
                    customers: customers,
                    onNewCustomer: () => setState(
                      () => _customer = _Controllers({
                        'name': '',
                        'street': '',
                        'postcode': '',
                        'city': '',
                        'country': 'DE',
                        'email': '',
                        'vat_id': '',
                        'reference': '',
                      }),
                    ),
                    onIssued: (issued) => setState(() => _issued = issued),
                  ),
                if (_issued case final issued?) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      Text(
                        '${t.invoiceWritten}: ${issued.number} · '
                        '${amount(issued.due.value, AppScope.of(context).lang)} ${issued.due.currency}',
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: Text(issued.name),
                        onPressed: () {
                          final state = AppScope.read(context);
                          saveFile(
                            context,
                            issued.name,
                            () => state.api!.original(books: state.books!, document: issued.document),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProfileForm extends StatelessWidget {
  _ProfileForm({required this.form, required this.canCancel, required this.onDone});

  final _Controllers form;
  final bool canCancel;
  final VoidCallback onDone;
  final _key = GlobalKey<FormState>();

  Future<void> _save(BuildContext context) async {
    if (!_key.currentState!.validate()) return;
    final state = AppScope.read(context);
    final body = InvoiceProfile(
      name: form.text('name'),
      street: form.text('street'),
      postcode: form.text('postcode'),
      city: form.text('city'),
      country: form.text('country').toUpperCase(),
      vatId: form.optional('vat_id'),
      taxNumber: form.optional('tax_number'),
      contact: form.text('contact'),
      phone: form.text('phone'),
      email: form.text('email'),
      iban: form.text('iban').replaceAll(' ', ''),
      paymentDays: int.parse(form.text('payment_days')),
      prefix: form.text('prefix'),
    );
    if (await act(context, () => state.api!.setProfile(books: state.books!, body: body))) onDone();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Panel(
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.seller, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Muted(t.sellerHint),
            const SizedBox(height: 16),
            Fields(
              children: [
                Input(label: t.name, controller: form['name']),
                Input(label: t.street, controller: form['street']),
                Input(label: t.postcode, controller: form['postcode']),
                Input(label: t.city, controller: form['city']),
                Input(label: t.country, controller: form['country'], validator: _country(t.countryInvalid)),
                Input(label: t.vatId, controller: form['vat_id'], required: false),
                Input(label: t.taxNumber, controller: form['tax_number'], required: false),
                Input(label: t.contact, controller: form['contact']),
                Input(label: t.phone, controller: form['phone']),
                Input(label: t.email, controller: form['email']),
                Input(label: 'IBAN', controller: form['iban']),
                Input(
                  label: t.paymentDays,
                  controller: form['payment_days'],
                  validator: (value) => int.tryParse(value) == null ? t.numberInvalid : null,
                ),
                Input(label: t.numberPrefix, controller: form['prefix']),
              ],
            ),
            const SizedBox(height: 16),
            ButtonRow([
              if (canCancel) OutlinedButton(onPressed: onDone, child: Text(t.cancel)),
              FilledButton(onPressed: () => _save(context), child: Text(t.keep)),
            ]),
          ],
        ),
      ),
    );
  }
}

String? Function(String) _country(String message) =>
    (value) => RegExp(r'^[A-Za-z]{2}$').hasMatch(value) ? null : message;

class _CustomerForm extends StatelessWidget {
  _CustomerForm({required this.form, required this.onDone});

  final _Controllers form;
  final ValueChanged<String?> onDone;
  final _key = GlobalKey<FormState>();

  Future<void> _save(BuildContext context) async {
    if (!_key.currentState!.validate()) return;
    final state = AppScope.read(context);
    final body = Customer(
      name: form.text('name'),
      street: form.text('street'),
      postcode: form.text('postcode'),
      city: form.text('city'),
      country: form.text('country').toUpperCase(),
      email: form.text('email'),
      vatId: form.optional('vat_id'),
      reference: form.optional('reference'),
    );
    Saved? saved;
    if (await act(context, () async => saved = await state.api!.saveCustomer(books: state.books!, body: body))) {
      onDone(saved?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Panel(
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.newCustomer, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Fields(
              children: [
                Input(label: t.name, controller: form['name']),
                Input(label: t.street, controller: form['street']),
                Input(label: t.postcode, controller: form['postcode']),
                Input(label: t.city, controller: form['city']),
                Input(label: t.country, controller: form['country'], validator: _country(t.countryInvalid)),
                Input(label: t.email, controller: form['email']),
                Input(label: t.vatId, controller: form['vat_id'], required: false),
                Input(label: t.buyerReference, controller: form['reference'], required: false),
              ],
            ),
            const SizedBox(height: 16),
            ButtonRow([
              OutlinedButton(onPressed: () => onDone(null), child: Text(t.cancel)),
              FilledButton(onPressed: () => _save(context), child: Text(t.keep)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _InvoiceForm extends StatefulWidget {
  const _InvoiceForm({required this.customers, required this.onNewCustomer, required this.onIssued});

  final List<Customer> customers;
  final VoidCallback onNewCustomer;
  final ValueChanged<Issued> onIssued;

  @override
  State<_InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<_InvoiceForm> {
  final _key = GlobalKey<FormState>();
  String _customer = '';
  String _date = today();
  String _delivery = '';
  final _note = TextEditingController();
  final _exemption = TextEditingController();
  String _format = 'xrechnung';
  List<_Line> _lines = [_Line()];

  @override
  void dispose() {
    _note.dispose();
    _exemption.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _issue() async {
    if (!_key.currentState!.validate()) return;
    final t = context.t;
    if (_customer.isEmpty) return complain(context, t.chooseCustomer);
    final state = AppScope.read(context);
    final body = NewInvoice(
      customer: _customer,
      date: _date,
      delivery: _delivery.isEmpty ? null : _delivery,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      exemption: _exemption.text.trim().isEmpty ? null : _exemption.text.trim(),
      format: _format,
      lines: [
        for (final line in _lines)
          InvoiceLineInput(
            name: line.name.text.trim(),
            quantity: parseAmount(line.quantity.text, state.lang)!,
            unit: line.unit,
            price: parseAmount(line.price.text, state.lang)!,
            tax: line.tax.isEmpty ? null : line.tax,
          ),
      ],
    );
    Issued? issued;
    if (!await act(context, () async => issued = await state.api!.issue(books: state.books!, body: body))) return;
    widget.onIssued(issued!);
    setState(() {
      for (final line in _lines) {
        line.dispose();
      }
      _lines = [_Line()];
      _delivery = '';
      _note.clear();
      _exemption.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang = AppScope.of(context).lang;
    String? amountValid(String value) => parseAmount(value, lang) == null ? t.amountInvalid : null;
    final taxes = {
      'de-out-19': '19 %',
      'de-out-7': '7 %',
      'de-out-0': '0 %',
      'de-out-exempt': t.taxExempt,
      'de-out-13b': t.tax13b,
      'de-out-eu-service': t.taxEuService,
      'de-out-ig-supply': t.taxIgSupply,
      'de-out-export': t.taxExport,
      '': t.smallBusinessLine,
    };
    return Panel(
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Loaded<NextNumber>(
              reload: [_date.length >= 4 ? _date.substring(0, 4) : ''],
              load: (api, books, state) => api.nextNumber(books: books, year: int.tryParse(_date.split('-').first)),
              builder: (context, next) =>
                  Text('${t.newInvoice} ${next.number}', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            Fields(
              children: [
                Choice(
                  label: t.customer,
                  value: _customer,
                  options: {'': '–', for (final c in widget.customers) c.id ?? '': c.name},
                  onChanged: (value) => setState(() => _customer = value),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(onPressed: widget.onNewCustomer, child: Text('+ ${t.newCustomer}')),
                ),
                DateField(label: t.date, value: _date, onChanged: (value) => setState(() => _date = value)),
                DateField(
                  label: t.deliveryDate,
                  value: _delivery,
                  required: false,
                  onChanged: (value) => _delivery = value,
                ),
              ],
            ),
            for (final (i, line) in _lines.indexed)
              Padding(
                key: ObjectKey(line),
                padding: const EdgeInsets.only(top: 14),
                child: Panel(
                  padding: const EdgeInsets.all(14),
                  child: Fields(
                    width: 180,
                    children: [
                      Input(label: t.service, controller: line.name),
                      Input(label: t.quantity, controller: line.quantity, number: true, validator: amountValid),
                      Choice(
                        label: t.unit,
                        value: line.unit,
                        options: {'HUR': t.hours, 'DAY': t.days, 'C62': t.pieces},
                        onChanged: (value) => setState(() => line.unit = value),
                      ),
                      Input(label: t.price, controller: line.price, number: true, validator: amountValid),
                      Choice(
                        label: t.taxCode,
                        value: line.tax,
                        options: taxes,
                        onChanged: (value) => setState(() => line.tax = value),
                      ),
                      if (_lines.length > 1)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() => _lines.removeAt(i).dispose()),
                            child: Text(t.remove),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            FormColumn(
              children: [
                if (_lines.any((line) => line.tax == 'de-out-exempt'))
                  TextFormField(
                    controller: _exemption,
                    decoration: InputDecoration(
                      labelText: t.exemptionReason,
                      hintText: 'Steuerfrei nach § 4 Nr. … UStG',
                    ),
                  ),
                TextField(
                  controller: _note,
                  decoration: InputDecoration(labelText: t.note),
                ),
                Choice(
                  label: t.invoiceFile,
                  value: _format,
                  options: const {'xrechnung': 'XRechnung (XML)', 'zugferd': 'ZUGFeRD (PDF)'},
                  onChanged: (value) => setState(() => _format = value),
                ),
                ButtonRow([
                  OutlinedButton(onPressed: () => setState(() => _lines.add(_Line())), child: Text(t.addLine)),
                  FilledButton(onPressed: _issue, child: Text(t.writeInvoice)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
