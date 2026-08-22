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
  final data = context.read<DataProvider>();
  final formKey = GlobalKey<FormState>();
  int? orderId = data.orders.isNotEmpty ? data.orders.first.orderId : null;
  int? workerId = data.workers.isNotEmpty ? data.workers.first.workerId : null;
  final stageCtrl = TextEditingController();
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
                  onPressed: (data.orders.isEmpty || data.workers.isEmpty)
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final now = DateTime.now();
                          await context.read<DataProvider>().addTask({
                            'orderId': orderId,
                            'workerId': workerId,
                            'stage': stageCtrl.text,
                            'status': status,
                            'startTime': now.toIso8601String(),
                            'endTime': now.add(const Duration(hours: 4)).toIso8601String(),
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
