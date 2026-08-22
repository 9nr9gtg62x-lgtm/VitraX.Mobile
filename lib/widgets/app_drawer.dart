import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../theme/vx_theme.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const AppDrawer({super.key, required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: VxColors.navy,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: VxColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('V', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  const Text('VitraX', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Glass Production', style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 12)),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            _tile(context, Icons.dashboard_rounded, 'لوحة التحكم', 0),
            _tile(context, Icons.precision_manufacturing_rounded, 'أوامر الإنتاج', 1),
            _tile(context, Icons.engineering_rounded, 'العمال', 2),
            _tile(context, Icons.assignment_rounded, 'المهام', 3),
            const Spacer(),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.white70),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                final authProvider = context.read<AuthProvider>();
                final dataProvider = context.read<DataProvider>();
                final navigator = Navigator.of(context);
                navigator.pop();
                await authProvider.logout();
                dataProvider.reset();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, int index) {
    final active = index == currentIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: active ? VxColors.secondaryFixed.withValues(alpha: .15) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: active ? VxColors.secondaryFixed : Colors.white70),
        title: Text(label, style: TextStyle(color: active ? VxColors.secondaryFixed : Colors.white70)),
        onTap: () {
          Navigator.pop(context);
          onSelect(index);
        },
      ),
    );
  }
}
