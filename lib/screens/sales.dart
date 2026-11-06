import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../store.dart';

/// 4. Product / Item Selection
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String q = '', cat = 'All';
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cats = [
      'All',
      ...{...s.products.map((p) => p.category)}
    ];
    final list = s.products
        .where((p) =>
            (cat == 'All' || p.category == cat) &&
            p.name.toLowerCase().contains(q.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Products',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false),
      floatingActionButton: s.cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              icon: Badge(
                  label: Text('${s.cartCount}'),
                  child: const Icon(Icons.shopping_cart)),
              label: Text(ugx(s.total)),
            ),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
                onChanged: (v) => setState(() => q = v),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search products...',
                    isDense: true))),
        SizedBox(
            height: 46,
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: cats
                    .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8, top: 6),
                        child: ChoiceChip(
                            label: Text(c),
                            selected: cat == c,
                            onSelected: (_) => setState(() => cat = c))))
                    .toList())),
        Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final p = list[i];
                      return Card(
                          child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
                            child: const Icon(Icons.local_mall_outlined)),
                        title: Text(p.name),
                        subtitle: Text('${ugx(p.price)}\nStock: ${p.stock}',
                            style: TextStyle(color: p.low ? Colors.red : null)),
                        isThreeLine: true,
                        trailing: IconButton.filled(
                            onPressed:
                                p.stock == 0 ? null : () => s.addToCart(p),
                            icon: const Icon(Icons.add)),
                      ));
                    },
                  )),
      ]),
    );
  }
}

/// 5. Create Sale / Checkout
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
          title: const Text('New Sale',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: s.cart.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : Column(children: [
              Expanded(
                  child: ListView(padding: const EdgeInsets.all(12), children: [
                Card(
                    child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(s.selectedCustomer?.name ?? 'Walk-in Customer'),
                  trailing: TextButton(
                      child: const Text('Change'),
                      onPressed: () => _pickCustomer(context, s)),
                )),
                ...s.cart.map((c) => Card(
                        child: ListTile(
                      title: Text(c.product.name),
                      subtitle: Text(ugx(c.product.price)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            onPressed: () => s.changeQty(c, -1),
                            icon: const Icon(Icons.remove_circle_outline)),
                        Text('${c.qty}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                            onPressed: () => s.changeQty(c, 1),
                            icon: const Icon(Icons.add_circle_outline)),
                        SizedBox(
                            width: 80,
                            child: Text(ugx(c.qty * c.product.price),
                                textAlign: TextAlign.end)),
                      ]),
                    ))),
              ])),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                    top: false,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _row('Subtotal', ugx(s.subtotal)),
                      _row('Tax (18%)', ugx(s.tax)),
                      const Divider(),
                      _row('Total', ugx(s.total), bold: true),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PaymentScreen())),
                          child: const Text('Proceed to Payment')),
                    ])),
              ),
            ]),
    );
  }

  static Widget _row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(a,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : null,
                  fontSize: bold ? 17 : 14)),
          Text(b,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : null,
                  fontSize: bold ? 17 : 14))
        ]),
      );

  void _pickCustomer(BuildContext context, AppState s) {
    showModalBottomSheet(
        context: context,
        builder: (_) => ListView(children: [
              ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Walk-in Customer'),
                  onTap: () {
                    s.selectCustomer(null);
                    Navigator.pop(context);
                  }),
              ...s.customers.map((c) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(c.name),
                  subtitle: Text(c.phone),
                  onTap: () {
                    s.selectCustomer(c);
                    Navigator.pop(context);
                  })),
            ]));
  }
}

/// 6. Payment Methods (cash, card, mobile money, bank transfer)
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String method = 'Cash';
  final tendered = TextEditingController(), phone = TextEditingController();
  bool busy = false;
  static const methods = {
    'Cash': Icons.payments_outlined,
    'Card': Icons.credit_card,
    'Mobile Money': Icons.phone_android,
    'Bank Transfer': Icons.account_balance
  };

  Future<void> pay() async {
    final s = context.read<AppState>();
    if (method == 'Cash' &&
        tendered.text.isNotEmpty &&
        (int.tryParse(tendered.text) ?? 0) < s.total) {
      return _msg('Amount tendered is less than the total');
    }
    if (method == 'Mobile Money' && phone.text.trim().length < 9)
      return _msg('Enter the MTN/Airtel number');
    setState(() => busy = true);
    // Simulated gateway: replace with MTN MoMo / Airtel / card processor SDK in production.
    if (method != 'Cash') await Future.delayed(const Duration(seconds: 1));
    final change = method == 'Cash' && tendered.text.isNotEmpty
        ? int.parse(tendered.text) - s.total
        : 0;
    final sale = s.completeSale(method);
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
    showDialog(
        context: context,
        builder: (_) => ReceiptDialog(
            sale: sale, change: change, business: s.businessName));
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Payment',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(
            child: Column(children: [
          const Text('Total Amount'),
          Text(ugx(s.total),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
        ])),
        const SizedBox(height: 16),
        RadioGroup<String>(
          groupValue: method,
          onChanged: (v) => setState(() => method = v ?? 'Cash'),
          child: Column(
            children: methods.entries
                .map((e) => Card(
                        child: RadioListTile<String>(
                      value: e.key,
                      title: Text(e.key),
                      secondary: Icon(e.value),
                      contentPadding: EdgeInsets.zero,
                    )))
                .toList(),
          ),
        ),
        if (method == 'Cash')
          TextField(
              controller: tendered,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Amount tendered (optional)')),
        if (method == 'Mobile Money')
          TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'MTN / Airtel number')),
        if (method == 'Card')
          const Text(
              'Card details are handled by the payment terminal / gateway. Raw card numbers are never stored in the app.',
              style: TextStyle(color: Colors.grey)),
        if (!s.online && method != 'Cash')
          const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                  'Offline: this payment will be queued and confirmed when you reconnect.',
                  style: TextStyle(color: Colors.orange))),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: busy ? null : pay,
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Pay Now')),
      ]),
    );
  }
}

class ReceiptDialog extends StatelessWidget {
  final Sale sale;
  final int change;
  final String business;
  const ReceiptDialog(
      {super.key,
      required this.sale,
      required this.change,
      required this.business});
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Column(children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          Text(business),
          const Text('Sale Complete', style: TextStyle(fontSize: 14))
        ]),
        content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
              '${sale.id}\n${DateFormat('d MMM yyyy, HH:mm').format(sale.date)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
          const Divider(),
          ...sale.lines.map((l) => CheckoutScreen._row(
              '${l.qty} x ${l.name}', ugx(l.qty * l.price))),
          const Divider(),
          CheckoutScreen._row('Subtotal', ugx(sale.subtotal)),
          CheckoutScreen._row('VAT 18%', ugx(sale.tax)),
          CheckoutScreen._row('Total', ugx(sale.total), bold: true),
          CheckoutScreen._row('Paid by', sale.method),
          if (change > 0) CheckoutScreen._row('Change', ugx(change)),
          if (!sale.synced)
            const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Saved offline – will sync automatically',
                    style: TextStyle(color: Colors.orange, fontSize: 12))),
        ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'))
        ],
      );
}
