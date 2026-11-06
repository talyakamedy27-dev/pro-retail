import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';

/// 8. Customer Management
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String q = '';
  void add(AppState s) {
    final n = TextEditingController(), p = TextEditingController();
    showModalBottomSheet(isScrollControlled: true, context: context, builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Add Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        TextField(controller: n, decoration: const InputDecoration(labelText: 'Full name')), const SizedBox(height: 10),
        TextField(controller: p, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (+256...)')), const SizedBox(height: 14),
        FilledButton(onPressed: () { if (n.text.trim().isEmpty) return; s.addCustomer(n.text.trim(), p.text.trim()); Navigator.pop(context); }, child: const Text('Save')),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.customers.where((c) => c.name.toLowerCase().contains(q.toLowerCase()) || c.phone.contains(q)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Customers', style: TextStyle(fontWeight: FontWeight.bold)), automaticallyImplyLeading: false),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v) => setState(() => q = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search customers...', isDense: true))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), children: list.map((c) => Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(c.name), subtitle: Text(c.phone),
          trailing: Text(ugx(s.spentBy(c.name)), style: const TextStyle(fontSize: 12)),
        ))).toList())),
        Padding(padding: const EdgeInsets.all(12), child: FilledButton.icon(onPressed: () => add(s), icon: const Icon(Icons.person_add), label: const Text('Add Customer'))),
      ]),
    );
  }
}
