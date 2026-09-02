import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/production_task.dart';
import '../providers/data_provider.dart';
import '../theme/vx_theme.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('مهمة جديدة'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataProvider>().loadAll(),
        child: data.tasks.isEmpty
            ? ListView(children: const [
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('لا توجد مهام بعد', style: TextStyle(color: Colors.grey))),
                ),
              ])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: data.tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final t = data.tasks[i];
                  return Card(
                    child: ListTile(
                      onTap: () => _showTaskDetailsSheet(context, t),
                      leading: CircleAvatar(
                        backgroundColor: VxColors.tertiary.withValues(alpha: .12),
                        child: Text('#${t.taskId}', style: const TextStyle(fontSize: 11, color: VxColors.tertiary)),
                      ),
                      title: Text(data.workerName(t.workerId), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${t.stage} · أمر #${t.orderId}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: vxStatusColor(t.status).withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                        child: Text(t.status, style: TextStyle(color: vxStatusColor(t.status), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

void _showTaskDetailsSheet(BuildContext context, ProductionTask t) {
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
            Text('مهمة #${t.taskId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VxColors.primary)),
            Text(t.stage, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            _row('أمر الإنتاج', '#${t.orderId}'),
            _row('العامل', data.workerName(t.workerId)),
            _row('الحالة', t.status),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: VxColors.error, side: const BorderSide(color: VxColors.error)),
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<DataProvider>().deleteTask(t.taskId);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف المهمة'),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

void _showAddTaskSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  int? orderId;
  int? workerId;
  final stageCtrl = TextEditingController();
  String status = 'قيد التنفيذ';
  var saving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          // Watch so the dropdowns stay in sync with DataProvider.orders/workers
          // even if they finish loading after this sheet is already open.
          final data = ctx.watch<DataProvider>();
          if (orderId == null && data.orders.isNotEmpty) orderId = data.orders.first.orderId;
          if (workerId == null && data.workers.isNotEmpty) workerId = data.workers.first.workerId;
          if (orderId != null && !data.orders.any((o) => o.orderId == orderId)) orderId = null;
          if (workerId != null && !data.workers.any((w) => w.workerId == workerId)) workerId = null;

          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            setSheetState(() => saving = true);
            final now = DateTime.now();
            final payload = {
              'orderId': orderId,
              'workerId': workerId,
              'stage': stageCtrl.text,
              'status': status,
              'startTime': now.toIso8601String(),
              'endTime': now.add(const Duration(hours: 4)).toIso8601String(),
            };
            debugPrint('[TasksTab] addTask request: $payload');
            try {
              await ctx.read<DataProvider>().addTask(payload);
              debugPrint('[TasksTab] addTask succeeded');
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ المهمة بنجاح')),
                );
              }
            } catch (e) {
              debugPrint('[TasksTab] addTask failed: $e');
              setSheetState(() => saving = false);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                );
              }
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  const Text('إضافة مهمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VxColors.primary)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: orderId,
                    decoration: const InputDecoration(labelText: 'أمر الإنتاج'),
                    items: data.orders.map((o) => DropdownMenuItem(value: o.orderId, child: Text('#${o.orderId} — ${data.productName(o.productId)}'))).toList(),
                    onChanged: (v) => setSheetState(() => orderId = v),
                    validator: (v) => v == null ? 'اختر أمراً' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: workerId,
                    decoration: const InputDecoration(labelText: 'العامل'),
                    items: data.workers.map((w) => DropdownMenuItem(value: w.workerId, child: Text(w.workerName))).toList(),
                    onChanged: (v) => setSheetState(() => workerId = v),
                    validator: (v) => v == null ? 'اختر عاملاً' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: stageCtrl,
                    decoration: const InputDecoration(labelText: 'المرحلة'),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (saving || data.orders.isEmpty || data.workers.isEmpty) ? null : submit,
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('حفظ'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
