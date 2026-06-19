import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
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

class KanjiZenApp extends ConsumerWidget {
  const KanjiZenApp({super.key});

  Color _getAccentColor(CyberAccent c) {
    switch (c) {
      case CyberAccent.green: return CyberTheme.defaultAccent;
      case CyberAccent.red: return CyberTheme.errorRed;
      case CyberAccent.orange: return Colors.orange;
      case CyberAccent.blue: return Colors.cyanAccent;
      case CyberAccent.purple: return Colors.purpleAccent;
      case CyberAccent.white: return Colors.white;
    }
  }

  double _getFontMultiplier(AppFontSize size) {
    switch (size) {
      case AppFontSize.auto: return 1.0;
      case AppFontSize.s: return 0.8;
      case AppFontSize.m: return 1.0;
      case AppFontSize.l: return 1.25;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final fontMulti = _getFontMultiplier(settings.fontSize);
    
    // El grosor del trazo lo vinculamos a si usa negrita
    final strokeMulti = settings.useBoldText ? 1.5 : 1.0;

    return MaterialApp.router(
      title: 'KanjiZen',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.themeData(
        accentColor: accent,
        fontMultiplier: fontMulti,
        strokeMultiplier: strokeMulti,
      ),
      routerConfig: appRouter,
    );
  }
}
