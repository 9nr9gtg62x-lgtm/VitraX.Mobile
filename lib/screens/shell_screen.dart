import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/app_drawer.dart';
import 'dashboard_tab.dart';
import 'orders_tab.dart';
import 'workers_tab.dart';
import 'tasks_tab.dart';

/// Single Scaffold shell shared by every tab: one AppBar, one Drawer,
/// one BottomNavigationBar — the "consistent design across the whole app"
/// requirement — with an IndexedStack swapping the four pages.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _titles = ['لوحة التحكم', 'أوامر الإنتاج', 'العمال', 'المهام'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_index]),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: data.isLoading ? null : () => context.read<DataProvider>().loadAll(),
            ),
          ],
        ),
        drawer: AppDrawer(currentIndex: _index, onSelect: (i) => setState(() => _index = i)),
        body: data.isLoading && data.products.isEmpty && data.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: _index,
                children: const [
                  DashboardTab(),
                  OrdersTab(),
                  WorkersTab(),
                  TasksTab(),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.precision_manufacturing_rounded), label: 'الأوامر'),
            BottomNavigationBarItem(icon: Icon(Icons.engineering_rounded), label: 'العمال'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'المهام'),
          ],
        ),
      ),
    );
  }
}
