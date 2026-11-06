import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import 'reports.dart';

/// 3. Home / Dashboard
class DashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = Theme.of(context).colorScheme.primary;
    final h = DateTime.now().hour;
    final greet = h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
    final y = s.salesOn(DateTime.now().subtract(const Duration(days: 1)));
    final pct = y == 0 ? null : ((s.todaySales - y) / y * 100).round();
    Widget action(IconData i, String t, VoidCallback f) => InkWell(
      onTap: f, borderRadius: BorderRadius.circular(12),
      child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: c, size: 30), const SizedBox(height: 6), Text(t)]))),
    );
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(child: Text('$greet,\n${s.businessName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const Icon(Icons.notifications_none), const SizedBox(width: 10),
          CircleAvatar(radius: 16, backgroundColor: c, child: const Icon(Icons.person, color: Colors.white, size: 18)),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Today's Sales", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(ugx(s.todaySales), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              if (pct != null) Text('${pct >= 0 ? '▲' : '▼'} ${pct.abs()}% vs yesterday', style: const TextStyle(color: Colors.white70)),
            ])),
            const Icon(Icons.bar_chart, color: Colors.white70, size: 40),
          ]),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.9,
          children: [
            action(Icons.shopping_cart, 'New Sale', () => onNavigate(1)),
            action(Icons.inventory_2, 'Inventory', () => onNavigate(2)),
            action(Icons.people, 'Customers', () => onNavigate(3)),
            action(Icons.bar_chart, 'Reports', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (s.sales.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No sales yet. Tap New Sale to start.', style: TextStyle(color: Colors.grey.shade600)))),
        ...s.sales.take(6).map((t) => Card(child: ListTile(
          leading: Icon(t.method == 'Cash' ? Icons.payments_outlined : t.method == 'Card' ? Icons.credit_card : Icons.phone_android, color: c),
          title: Text('${t.method} Sale'), subtitle: Text('${t.customer} • ${DateFormat('d MMM, HH:mm').format(t.date)}'),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(ugx(t.total), style: const TextStyle(fontWeight: FontWeight.bold)),
            if (!t.synced) const Text('pending sync', style: TextStyle(fontSize: 10, color: Colors.orange)),
          ]),
        ))),
      ]),
    );
  }
}
