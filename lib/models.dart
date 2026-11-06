class Product {
  final String id;
  String name, category;
  int price, stock, reorder;
  Product({required this.id, required this.name, required this.price, required this.stock, this.reorder = 10, this.category = 'General'});
  bool get low => stock <= reorder;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price, 'stock': stock, 'reorder': reorder, 'category': category};
  factory Product.fromJson(Map<String, dynamic> j) => Product(id: j['id'], name: j['name'], price: j['price'], stock: j['stock'], reorder: j['reorder'], category: j['category']);
}

class Customer {
  final String id;
  String name, phone;
  Customer({required this.id, required this.name, required this.phone});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};
  factory Customer.fromJson(Map<String, dynamic> j) => Customer(id: j['id'], name: j['name'], phone: j['phone']);
}

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, this.qty);
}

class SaleLine {
  final String name;
  final int qty, price;
  SaleLine(this.name, this.qty, this.price);
  Map<String, dynamic> toJson() => {'n': name, 'q': qty, 'p': price};
  factory SaleLine.fromJson(Map<String, dynamic> j) => SaleLine(j['n'], j['q'], j['p']);
}

class Sale {
  final String id, method, customer;
  final DateTime date;
  final List<SaleLine> lines;
  final int subtotal, tax, total;
  bool synced;
  Sale({required this.id, required this.method, required this.customer, required this.date, required this.lines, required this.subtotal, required this.tax, required this.total, this.synced = false});
  Map<String, dynamic> toJson() => {'id': id, 'm': method, 'c': customer, 'd': date.toIso8601String(), 'l': lines.map((e) => e.toJson()).toList(), 's': subtotal, 't': tax, 'T': total, 'y': synced};
  factory Sale.fromJson(Map<String, dynamic> j) => Sale(id: j['id'], method: j['m'], customer: j['c'], date: DateTime.parse(j['d']), lines: (j['l'] as List).map((e) => SaleLine.fromJson(e)).toList(), subtotal: j['s'], tax: j['t'], total: j['T'], synced: j['y'] ?? false);
}
