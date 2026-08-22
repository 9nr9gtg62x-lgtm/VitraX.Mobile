import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/vx_theme.dart';
import 'login_screen.dart';
import 'shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      auth.restoreSession(),
      Future.delayed(const Duration(milliseconds: 900)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => auth.status == AuthStatus.authenticated ? const ShellScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VxColors.navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: VxColors.primary, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('VitraX', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text('Glass Production Excellence', style: TextStyle(color: Colors.white.withValues(alpha: .6))),
            const SizedBox(height: 32),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: VxColors.secondaryFixed)),
          ],
        ),
      ),
    );
  }
}
