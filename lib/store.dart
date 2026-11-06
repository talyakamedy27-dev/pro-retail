import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

String ugx(num v) => 'UGX ${NumberFormat('#,##0').format(v)}';
String hash(String s) => sha256.convert(utf8.encode('pos-salt:$s')).toString();

/// Central app state. All data is persisted locally (offline-first) and
/// sales are queued and marked "synced" once a connection is available.
class AppState extends ChangeNotifier {
  static const taxRate = 0.18; // Uganda VAT
  SharedPreferences? _prefs;
  StreamSubscription? _sub;

  List<Product> products = [];
  List<Customer> customers = [];
  List<Sale> sales = [];
  Map<String, String> users = {}; // email -> password hash
  String? currentUser;
  String businessName = 'My Store', businessType = 'Retail Store';
  int themeColor = 0xFF1F6FEB;
  bool online = true;

  final List<CartItem> cart = [];
  Customer? selectedCustomer;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('data');
    if (raw == null) {
      _seed();
      await _save();
    } else {
      final j = jsonDecode(raw);
      products = (j['products'] as List).map((e) => Product.fromJson(e)).toList();
      customers = (j['customers'] as List).map((e) => Customer.fromJson(e)).toList();
      sales = (j['sales'] as List).map((e) => Sale.fromJson(e)).toList();
      users = Map<String, String>.from(j['users']);
      businessName = j['bn'];
      businessType = j['bt'];
      themeColor = j['tc'];
    }
    final c = await Connectivity().checkConnectivity();
    online = !c.contains(ConnectivityResult.none);
    _sub = Connectivity().onConnectivityChanged.listen((r) {
      online = !r.contains(ConnectivityResult.none);
      if (online) _syncPending();
      notifyListeners();
    });
    if (online) _syncPending();
  }

  void _seed() {
    users = {'owner@business.com': hash('admin123')};
    products = [
      Product(id: 'p1', name: 'Coca Cola 500ml', price: 2500, stock: 50, reorder: 20, category: 'Beverages'),
      Product(id: 'p2', name: 'Sprite 500ml', price: 2500, stock: 40, reorder: 20, category: 'Beverages'),
      Product(id: 'p3', name: 'Water 500ml', price: 1500, stock: 100, reorder: 30, category: 'Beverages'),
      Product(id: 'p4', name: 'Bread', price: 3000, stock: 30, reorder: 10, category: 'Groceries'),
      Product(id: 'p5', name: 'Chips', price: 2000, stock: 45, reorder: 15, category: 'Snacks'),
    ];
    customers = [
      Customer(id: 'c1', name: 'John Mwangi', phone: '+256 700 123 456'),
      Customer(id: 'c2', name: 'Sarah Nakato', phone: '+256 772 987 654'),
      Customer(id: 'c3', name: 'David Kato', phone: '+256 703 456 789'),
    ];
  }

  Future<void> _save() async {
    await _prefs?.setString('data', jsonEncode({
      'products': products.map((e) => e.toJson()).toList(),
      'customers': customers.map((e) => e.toJson()).toList(),
      'sales': sales.map((e) => e.toJson()).toList(),
      'users': users, 'bn': businessName, 'bt': businessType, 'tc': themeColor,
    }));
  }

  void _syncPending() {
    // Placeholder for a real API call: pending sales are uploaded when online.
    for (final s in sales) { s.synced = true; }
    _save();
  }

  int get pendingSync => sales.where((s) => !s.synced).length;

  // ---- Auth ----
  bool login(String email, String pass) {
    if (users[email.trim().toLowerCase()] == hash(pass)) {
      currentUser = email.trim().toLowerCase();
      notifyListeners();
      return true;
    }
    return false;
  }

  String? signUp(String email, String pass) {
    final e = email.trim().toLowerCase();
    if (!e.contains('@') || pass.length < 6) return 'Enter a valid email and a password of 6+ characters';
    if (users.containsKey(e)) return 'Account already exists';
    users[e] = hash(pass);
    _save();
    return null;
  }

  void logout() { currentUser = null; cart.clear(); notifyListeners(); }

  // ---- Cart ----
  void addToCart(Product p) {
    final i = cart.indexWhere((c) => c.product.id == p.id);
    if (i >= 0) { if (cart[i].qty < p.stock) cart[i].qty++; } else if (p.stock > 0) { cart.add(CartItem(p, 1)); }
    notifyListeners();
  }

  void changeQty(CartItem c, int d) {
    c.qty += d;
    if (c.qty <= 0) cart.remove(c);
    if (c.qty > c.product.stock) c.qty = c.product.stock;
    notifyListeners();
  }

  int get cartCount => cart.fold(0, (a, c) => a + c.qty);
  int get subtotal => cart.fold(0, (a, c) => a + c.qty * c.product.price);
  int get tax => (subtotal * taxRate).round();
  int get total => subtotal + tax;

  void selectCustomer(Customer? c) { selectedCustomer = c; notifyListeners(); }

  Sale completeSale(String method) {
    final sale = Sale(
      id: 'S${DateTime.now().millisecondsSinceEpoch}', method: method,
      customer: selectedCustomer?.name ?? 'Walk-in Customer', date: DateTime.now(),
      lines: cart.map((c) => SaleLine(c.product.name, c.qty, c.product.price)).toList(),
      subtotal: subtotal, tax: tax, total: total, synced: online,
    );
    for (final c in cart) { c.product.stock -= c.qty; }
    sales.insert(0, sale);
    cart.clear();
    selectedCustomer = null;
    _save();
    notifyListeners();
    return sale;
  }

  // ---- Inventory / customers / settings ----
  void saveProduct(Product p, {bool isNew = false}) { if (isNew) products.add(p); _save(); notifyListeners(); }
  void deleteProduct(Product p) { products.remove(p); _save(); notifyListeners(); }
  void addCustomer(String name, String phone) {
    customers.add(Customer(id: 'c${DateTime.now().millisecondsSinceEpoch}', name: name, phone: phone));
    _save(); notifyListeners();
  }
  void updateProfile(String name, String type, int color) {
    businessName = name; businessType = type; themeColor = color; _save(); notifyListeners();
  }

  // ---- Analytics (computed live from local data) ----
  int salesOn(DateTime d) => sales.where((s) => s.date.year == d.year && s.date.month == d.month && s.date.day == d.day).fold(0, (a, s) => a + s.total);
  int get todaySales => salesOn(DateTime.now());
  List<int> lastDays(int n) { final now = DateTime.now(); return List.generate(n, (i) => salesOn(now.subtract(Duration(days: n - 1 - i)))); }
  int totalFor(int days) => lastDays(days).fold(0, (a, b) => a + b);
  Map<String, int> get byMethod { final m = <String, int>{}; for (final s in sales) { m[s.method] = (m[s.method] ?? 0) + s.total; } return m; }
  List<MapEntry<String, int>> get topProducts {
    final m = <String, int>{};
    for (final s in sales) { for (final l in s.lines) { m[l.name] = (m[l.name] ?? 0) + l.qty; } }
    return (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();
  }
  int spentBy(String name) => sales.where((s) => s.customer == name).fold(0, (a, s) => a + s.total);
  int get stockValue => products.fold(0, (a, p) => a + p.price * p.stock);

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
