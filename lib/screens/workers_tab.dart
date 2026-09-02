import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker.dart';
import '../providers/data_provider.dart';
import '../theme/vx_theme.dart';

class WorkersTab extends StatelessWidget {
  const WorkersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkerSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('عامل جديد'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DataProvider>().loadAll(),
        child: data.workers.isEmpty
            ? ListView(children: const [
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('لا يوجد عمال بعد', style: TextStyle(color: Colors.grey))),
                ),
              ])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: data.workers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final w = data.workers[i];
                  return Card(
                    child: ListTile(
                      onTap: () => _showWorkerDetailsSheet(context, w),
                      leading: CircleAvatar(
                        backgroundColor: VxColors.primary.withValues(alpha: .1),
                        backgroundImage: w.imagePath.isNotEmpty ? NetworkImage(w.imagePath) : null,
                        child: w.imagePath.isEmpty ? const Icon(Icons.person, color: VxColors.primary) : null,
                      ),
                      title: Text(w.workerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(w.role),
                      trailing: Text(w.phone, style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

void _showWorkerDetailsSheet(BuildContext context, Worker w) {
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
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: VxColors.primary.withValues(alpha: .1),
                  backgroundImage: w.imagePath.isNotEmpty ? NetworkImage(w.imagePath) : null,
                  child: w.imagePath.isEmpty ? const Icon(Icons.person, color: VxColors.primary, size: 28) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.workerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(w.role, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الهاتف', style: TextStyle(color: Colors.grey)),
                Text(w.phone, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: VxColors.error, side: const BorderSide(color: VxColors.error)),
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<DataProvider>().deleteWorker(w.workerId);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف العامل'),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAddWorkerSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  var saving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            setSheetState(() => saving = true);
            final data = {
              'workerName': nameCtrl.text,
              'role': roleCtrl.text,
              'phone': phoneCtrl.text,
              'imagePath': imageCtrl.text,
            };
            debugPrint('[WorkersTab] addWorker request: $data');
            try {
              await ctx.read<DataProvider>().addWorker(data);
              debugPrint('[WorkersTab] addWorker succeeded');
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ العامل بنجاح')),
                );
              }
            } catch (e) {
              debugPrint('[WorkersTab] addWorker failed: $e');
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
                  const Text('إضافة عامل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VxColors.primary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم العامل'),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'الدور')),
                  const SizedBox(height: 12),
                  TextFormField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'الهاتف')),
                  const SizedBox(height: 12),
                  TextFormField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'رابط الصورة (اختياري)')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saving ? null : submit,
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
