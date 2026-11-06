import 'package:flutter_test/flutter_test.dart';
import 'package:pos_retail_pro/models.dart';
import 'package:pos_retail_pro/store.dart';

void main() {
  test('totals include 18% VAT and stock is reduced after a sale', () {
    final s = AppState();
    final p = Product(id: 'x', name: 'Test', price: 1000, stock: 5);
    s.products = [p];
    s.addToCart(p);
    s.addToCart(p);
    expect(s.subtotal, 2000);
    expect(s.tax, 360);
    expect(s.total, 2360);
    s.completeSale('Cash');
    expect(p.stock, 3);
    expect(s.sales.length, 1);
  });
}
