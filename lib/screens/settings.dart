import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import 'auth.dart';

/// 10. Settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    void soon(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$t – configured per business in a future release')));
    Widget item(IconData i, String t, VoidCallback f) => ListTile(
        leading: Icon(i),
        title: Text(t),
        trailing: const Icon(Icons.chevron_right),
        onTap: f);
    return Scaffold(
      appBar: AppBar(
          title: const Text('Settings',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false),
      body: ListView(children: [
        ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(s.businessName),
            subtitle: Text(s.currentUser ?? '')),
        const Divider(),
        item(
            Icons.storefront,
            'Business Profile',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BusinessProfileScreen()))),
        item(Icons.payment, 'Payment Settings', () => soon('Payment gateways')),
        item(Icons.inventory, 'Inventory Settings',
            () => soon('Inventory rules')),
        item(Icons.manage_accounts, 'User Management',
            () => soon('Roles & permissions')),
        item(
            Icons.wifi_off,
            'Offline Status',
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OfflineScreen()))),
        item(
            Icons.security,
            'Security & Privacy',
            () => showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                      title: Text('Security & Privacy'),
                      content: Text(
                          '• Passwords are salted and hashed (SHA-256), never stored in plain text.\n• Data stays on the device and is only shared with your own account.\n• Card numbers are never stored; payments go through the gateway.\n• Designed to follow the Uganda Data Protection and Privacy Act, 2019.'),
                    ))),
        item(
            Icons.info_outline,
            'About',
            () => showAboutDialog(
                context: context,
                applicationName: 'POS Retail Pro',
                applicationVersion: '1.0.0')),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {
              s.logout();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
            }),
      ]),
    );
  }
}

/// 11. Offline Mode
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Connection')),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(s.online ? Icons.wifi : Icons.wifi_off,
                        size: 44,
                        color: s.online ? Colors.green : Colors.grey)),
                const SizedBox(height: 16),
                Text(s.online ? "You're Online" : "You're Offline",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    s.online
                        ? 'All data is synced.'
                        : 'No internet connection detected. You can still process sales, view cached data and manage inventory.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Chip(
                    avatar: const Icon(Icons.check_circle, size: 18),
                    label: Text(s.online ? 'Online' : 'Working Offline')),
                Text('${s.pendingSync} sale(s) waiting to sync'),
              ]))),
    );
  }
}

/// 12. Customization (Business Profile)
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});
  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  late final TextEditingController name;
  late String type;
  late int color;
  static const types = [
    'Retail Store',
    'Restaurant',
    'Pharmacy',
    'Supermarket',
    'Electronics',
    'Other'
  ];
  static const colors = [
    0xFF7B2FF7,
    0xFF1F6FEB,
    0xFF2EAD4B,
    0xFFF2C94C,
    0xFFF2994A
  ];

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    name = TextEditingController(text: s.businessName);
    type = types.contains(s.businessType) ? s.businessType : 'Other';
    color = s.themeColor;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Business Profile',
                style: TextStyle(fontWeight: FontWeight.bold))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Business Name'),
          const SizedBox(height: 6),
          TextField(controller: name),
          const SizedBox(height: 16),
          const Text('Business Type'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
              initialValue: type,
              items: types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => type = v!)),
          const SizedBox(height: 16),
          const Text('Theme Color'),
          const SizedBox(height: 8),
          Row(
              children: colors
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => color = c),
                        child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: Color(c),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 3,
                                    color: color == c
                                        ? Colors.black87
                                        : Colors.transparent))),
                      ))
                  .toList()),
          const SizedBox(height: 28),
          FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                context
                    .read<AppState>()
                    .updateProfile(name.text.trim(), type, color);
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ]),
      );
}
