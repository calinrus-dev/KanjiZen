import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kanjizen_app/src/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación portrait fija
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // UI overlay oscura (status bar transparente sobre bgObsidian)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CyberTheme.bgObsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: KanjiZenApp()));
}

class KanjiZenApp extends StatelessWidget {
  const KanjiZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KanjiZen',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.themeData,
      routerConfig: appRouter,
    );
  }
}
