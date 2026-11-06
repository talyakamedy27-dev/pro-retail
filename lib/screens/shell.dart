import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import 'dashboard.dart';
import 'sales.dart';
import 'inventory.dart';
import 'customers.dart';
import 'settings.dart';

/// Bottom-navigation shell with an offline banner shown on every tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pages = [DashboardScreen(onNavigate: go), const ProductsScreen(), const InventoryScreen(), const CustomersScreen(), const SettingsScreen()];
    return Scaffold(
      body: Column(children: [
        if (!s.online)
          Material(
            color: Colors.orange.shade700,
            child: SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 16), const SizedBox(width: 8),
                Expanded(child: Text('Working offline • ${s.pendingSync} sale(s) will sync automatically', style: const TextStyle(color: Colors.white, fontSize: 12))),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineScreen())), child: const Text('Details', style: TextStyle(color: Colors.white))),
              ]),
            )),
          ),
        Expanded(child: IndexedStack(index: index, children: pages)),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index, onDestinationSelected: go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
