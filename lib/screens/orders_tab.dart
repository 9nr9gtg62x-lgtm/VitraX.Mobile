import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../models/production_order.dart';
import '../providers/data_provider.dart';
import '../theme/vx_theme.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrderSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('أمر جديد'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataProvider>().loadAll(),
        child: data.orders.isEmpty
            ? ListView(children: const [
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('لا توجد أوامر إنتاج بعد', style: TextStyle(color: Colors.grey))),
                ),
              ])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: data.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final o = data.orders[i];
                  return Card(
                    child: ListTile(
                      onTap: () => _showOrderDetailsSheet(context, o),
                      leading: CircleAvatar(
                        backgroundColor: VxColors.primary.withValues(alpha: .1),
                        child: Text('#${o.orderId}', style: const TextStyle(fontSize: 11, color: VxColors.primary)),
                      ),
                      title: Text(data.productName(o.productId), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('الكمية: ${o.quantity} · ${DateFormat('yyyy-MM-dd').format(o.startDate)}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: vxStatusColor(o.status).withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                        child: Text(o.status, style: TextStyle(color: vxStatusColor(o.status), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

void _showOrderDetailsSheet(BuildContext context, ProductionOrder o) {
  final data = context.read<DataProvider>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('أمر رقم #${o.orderId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VxColors.primary)),
            Text(data.productName(o.productId), style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            _detailRow('الكمية', '${o.quantity}'),
            _detailRow('الحالة', o.status),
            _detailRow('تاريخ البدء', DateFormat('yyyy-MM-dd').format(o.startDate)),
            _detailRow('تاريخ الانتهاء', DateFormat('yyyy-MM-dd').format(o.endDate)),
            if (o.notes.isNotEmpty) _detailRow('ملاحظات', o.notes),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: VxColors.error, side: const BorderSide(color: VxColors.error)),
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<DataProvider>().deleteOrder(o.orderId);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف الأمر'),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _detailRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.left)),
        ],
      ),
    );

void _showAddOrderSheet(BuildContext context) {
  final data = context.read<DataProvider>();
  final formKey = GlobalKey<FormState>();
  int? productId = data.products.isNotEmpty ? data.products.first.productId : null;
  final qtyCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  String status = 'قيد التنفيذ';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('إضافة أمر إنتاج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VxColors.primary)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: productId,
                  decoration: const InputDecoration(labelText: 'المنتج'),
                  items: data.products.map((p) => DropdownMenuItem(value: p.productId, child: Text(p.productName))).toList(),
                  onChanged: (v) => setSheetState(() => productId = v),
                  validator: (v) => v == null ? 'اختر منتجاً' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'أدخل رقماً صحيحاً' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: const [
                    DropdownMenuItem(value: 'قيد التنفيذ', child: Text('قيد التنفيذ')),
                    DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                    DropdownMenuItem(value: 'متوقف', child: Text('متوقف')),
                  ],
                  onChanged: (v) => setSheetState(() => status = v ?? status),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final now = DateTime.now();
                    await context.read<DataProvider>().addOrder({
                      'productId': productId,
                      'quantity': int.parse(qtyCtrl.text),
                      'startDate': now.toIso8601String(),
                      'endDate': now.add(const Duration(days: 7)).toIso8601String(),
                      'status': status,
                      'notes': notesCtrl.text,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
