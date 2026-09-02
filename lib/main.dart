import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/vx_theme.dart';

/// Accepts the ASP.NET Core dev server's self-signed HTTPS certificate.
/// Debug-only: never trust arbitrary certs in a release build.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  if (kDebugMode && !kIsWeb) {
    HttpOverrides.global = _DevHttpOverrides();
  }
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
