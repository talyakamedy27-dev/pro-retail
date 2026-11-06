import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../store.dart';

/// 7. Inventory Management (Stock / Low Stock / Categories)
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int tab = 0;
  String q = '';

  void edit(AppState s, [Product? p]) {
    final name = TextEditingController(text: p?.name), price = TextEditingController(text: p?.price.toString()),
        stock = TextEditingController(text: p?.stock.toString()), reorder = TextEditingController(text: p?.reorder.toString() ?? '10'),
        cat = TextEditingController(text: p?.category ?? 'General');
    showModalBottomSheet(isScrollControlled: true, context: context, builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(p == null ? 'Add Product' : 'Edit Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), const SizedBox(height: 10),
        TextField(controller: cat, decoration: const InputDecoration(labelText: 'Category')), const SizedBox(height: 10),
        TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (UGX)')), const SizedBox(height: 10),
        TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock')), const SizedBox(height: 10),
        TextField(controller: reorder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reorder level')), const SizedBox(height: 14),
        FilledButton(onPressed: () {
          if (name.text.trim().isEmpty || int.tryParse(price.text) == null || int.tryParse(stock.text) == null) return;
          final item = p ?? Product(id: 'p${DateTime.now().millisecondsSinceEpoch}', name: '', price: 0, stock: 0);
          item..name = name.text.trim()..category = cat.text.trim()..price = int.parse(price.text)..stock = int.parse(stock.text)..reorder = int.tryParse(reorder.text) ?? 10;
          s.saveProduct(item, isNew: p == null);
          Navigator.pop(context);
        }, child: const Text('Save')),
        if (p != null) TextButton(onPressed: () { s.deleteProduct(p); Navigator.pop(context); }, child: const Text('Delete product', style: TextStyle(color: Colors.red))),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    var list = s.products.where((p) => p.name.toLowerCase().contains(q.toLowerCase())).toList();
    if (tab == 1) list = list.where((p) => p.low).toList();
    final cats = <String, int>{};
    for (final p in s.products) { cats[p.category] = (cats[p.category] ?? 0) + 1; }
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.bold)), automaticallyImplyLeading: false),
      floatingActionButton: FloatingActionButton(onPressed: () => edit(s), child: const Icon(Icons.add)),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: SegmentedButton<int>(
          segments: const [ButtonSegment(value: 0, label: Text('Stock')), ButtonSegment(value: 1, label: Text('Low Stock')), ButtonSegment(value: 2, label: Text('Categories'))],
          selected: {tab}, onSelectionChanged: (v) => setState(() => tab = v.first),
        )),
        if (tab != 2) Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: TextField(onChanged: (v) => setState(() => q = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search inventory...', isDense: true))),
        Expanded(child: tab == 2
          ? ListView(children: cats.entries.map((e) => ListTile(leading: const Icon(Icons.category_outlined), title: Text(e.key), trailing: Text('${e.value} items'))).toList())
          : list.isEmpty ? const Center(child: Text('Nothing to show')) : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80), itemCount: list.length,
              itemBuilder: (_, i) { final p = list[i]; return Card(child: ListTile(
                onTap: () => edit(s, p),
                leading: const Icon(Icons.inventory_2_outlined), title: Text(p.name),
                subtitle: Text('Stock: ${p.stock}   Reorder: ${p.reorder}', style: TextStyle(color: p.low ? Colors.red : null)),
                trailing: p.low ? const Icon(Icons.warning_amber, color: Colors.red) : const Icon(Icons.chevron_right),
              )); },
            )),
      ]),
    );
  }
}
