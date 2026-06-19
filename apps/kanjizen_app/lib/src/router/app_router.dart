import 'package:go_router/go_router.dart';
import 'package:kanjizen_app/src/features/splash/presentation/splash_screen.dart';
import 'package:kanjizen_app/src/features/auth/presentation/auth_screen.dart';
import 'package:kanjizen_app/src/features/home/presentation/engine_selector_screen.dart';
import 'package:kanjizen_app/src/features/inventory/presentation/inventory_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
    GoRoute(
      path: '/home',
      builder: (_, __) => const EngineSelectorScreen(),
      routes: [
        GoRoute(path: 'inventory', builder: (_, __) => const InventoryScreen()),
      ],
    ),
  ],
);
