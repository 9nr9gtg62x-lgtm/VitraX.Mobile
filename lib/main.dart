import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/vx_theme.dart';

void main() {
  runApp(const VitraXApp());
}

class VitraXApp extends StatelessWidget {
  const VitraXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'VitraX',
        debugShowCheckedModeBanner: false,
        theme: VxTheme.light,
        locale: const Locale('ar'),
        home: const SplashScreen(),
      ),
    );
  }
}
