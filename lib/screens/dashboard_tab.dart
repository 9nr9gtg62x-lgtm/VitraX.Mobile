import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/vx_theme.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return RefreshIndicator(
      onRefresh: () => context.read<DataProvider>().loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _KpiCard(icon: Icons.inventory_2_rounded, label: 'المنتجات', value: data.products.length, color: VxColors.primary),
              _KpiCard(icon: Icons.precision_manufacturing_rounded, label: 'أوامر الإنتاج', value: data.orders.length, color: VxColors.secondary),
              _KpiCard(icon: Icons.check_circle_rounded, label: 'المهام', value: data.tasks.length, color: VxColors.tertiary),
              _KpiCard(icon: Icons.engineering_rounded, label: 'العمال', value: data.workers.length, color: VxColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('أحدث أوامر الإنتاج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (data.orders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('لا توجد أوامر إنتاج بعد', style: TextStyle(color: Colors.grey))),
            )
          else
            ...data.orders.take(5).map((o) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: VxColors.primary.withValues(alpha: .1),
                      child: Text('#${o.orderId}', style: const TextStyle(fontSize: 11, color: VxColors.primary)),
                    ),
                    title: Text(data.productName(o.productId), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('الكمية: ${o.quantity}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: vxStatusColor(o.status).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(o.status, style: TextStyle(color: vxStatusColor(o.status), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _KpiCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
