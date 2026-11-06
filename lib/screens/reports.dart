import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../store.dart';

/// 9. Reports & Analytics – computed in real time from local data.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int days = 7;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = Theme.of(context).colorScheme.primary;
    final data = s.lastDays(days);
    final labels = List.generate(
        days,
        (i) => DateFormat('d/M')
            .format(DateTime.now().subtract(Duration(days: days - 1 - i))));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Reports',
                style: TextStyle(fontWeight: FontWeight.bold)),
            bottom: const TabBar(tabs: [
              Tab(text: 'Sales'),
              Tab(text: 'Inventory'),
              Tab(text: 'Customers')
            ])),
        body: TabBarView(children: [
          ListView(padding: const EdgeInsets.all(16), children: [
            SegmentedButton<int>(segments: const [
              ButtonSegment(value: 7, label: Text('7 Days')),
              ButtonSegment(value: 30, label: Text('30 Days'))
            ], selected: {
              days
            }, onSelectionChanged: (v) => setState(() => days = v.first)),
            const SizedBox(height: 14),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Sales'),
                          Text(ugx(s.totalFor(days)),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('${s.sales.length} transactions overall',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ]))),
            const SizedBox(height: 8),
            const Text('Sales Trend',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
                height: 190,
                child: CustomPaint(
                    painter: LineChartPainter(data, labels, c),
                    size: Size.infinite)),
            const SizedBox(height: 12),
            const Text('Top Products',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...s.topProducts.map((e) => ListTile(
                dense: true,
                title: Text(e.key),
                trailing: Text('${e.value} sold'))),
            if (s.topProducts.isEmpty) const Text('No sales data yet'),
            const SizedBox(height: 8),
            const Text('Payment Methods',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...s.byMethod.entries.map((e) => ListTile(
                dense: true, title: Text(e.key), trailing: Text(ugx(e.value)))),
          ]),
          ListView(padding: const EdgeInsets.all(16), children: [
            Card(
                child: ListTile(
                    title: const Text('Stock value'),
                    trailing: Text(ugx(s.stockValue)))),
            Card(
                child: ListTile(
                    title: const Text('Products'),
                    trailing: Text('${s.products.length}'))),
            Card(
                child: ListTile(
                    title: const Text('Low stock items'),
                    trailing: Text('${s.products.where((p) => p.low).length}',
                        style: const TextStyle(color: Colors.red)))),
          ]),
          ListView(padding: const EdgeInsets.all(16), children: [
            Card(
                child: ListTile(
                    title: const Text('Total customers'),
                    trailing: Text('${s.customers.length}'))),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Top spenders',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            ...(([
              ...s.customers
            ]..sort((a, b) => s.spentBy(b.name).compareTo(s.spentBy(a.name))))
                .take(5)
                .map((cu) => ListTile(
                    title: Text(cu.name),
                    trailing: Text(ugx(s.spentBy(cu.name)))))),
          ]),
        ]),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels;
  final Color color;
  LineChartPainter(this.data, this.labels, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    const pad = 22.0;
    final maxV =
        (data.reduce((a, b) => a > b ? a : b)).clamp(1, 1 << 40).toDouble();
    final w = size.width, h = size.height - pad;
    final grid = Paint()..color = Colors.grey.shade300;
    for (var i = 0; i <= 3; i++) {
      canvas.drawLine(Offset(0, h * i / 3), Offset(w, h * i / 3), grid);
    }
    final pts = [
      for (var i = 0; i < data.length; i++)
        Offset(data.length == 1 ? w / 2 : w * i / (data.length - 1),
            h - h * data[i] / maxV * 0.95)
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    for (final p in pts) {
      canvas.drawCircle(p, 3, Paint()..color = color);
    }
    final step = (data.length / 6).ceil();
    for (var i = 0; i < labels.length; i += step) {
      final tp = TextPainter(
          text: TextSpan(
              text: labels[i],
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          textDirection: ui.TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(pts[i].dx - tp.width / 2, h + 5));
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) => old.data != data;
}

