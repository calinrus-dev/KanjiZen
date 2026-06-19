import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(path: 'inventory', builder: (_, __) => const InventoryScreen()),
      ],
    ),
  ],
);
