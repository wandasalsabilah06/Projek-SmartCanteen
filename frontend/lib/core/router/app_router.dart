import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/menu/screens/menu_detail_screen.dart';
import '../../features/menu/screens/menu_list_screen.dart';
import '../../features/orders/screens/order_history_screen.dart';
import '../../features/orders/screens/order_pickup_screen.dart';
import '../../features/orders/screens/order_tracking_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Route yang membutuhkan login
  static const _authRequired = [
    '/cart',
    '/checkout',
    '/orders',
    '/history',
    '/profile',
    '/order',
  ];

  static bool _needsAuth(String location) {
    return _authRequired.any((r) => location.startsWith(r));
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Redirect guard ───────────────────────────────────────────────────────
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Splash & login tidak perlu dicek
      if (location == AppRoutes.splash || location == AppRoutes.login) {
        return null;
      }

      // Cek apakah route perlu login
      if (_needsAuth(location)) {
        final authProvider = Provider.of<AuthProvider>(
          _rootNavigatorKey.currentContext!,
          listen: false,
        );
        if (!authProvider.isAuthenticated) {
          // Simpan tujuan asal agar bisa balik setelah login
          return '${AppRoutes.login}?from=${Uri.encodeComponent(location)}';
        }
      }

      return null;
    },

    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Main Shell — Home, Orders, History, Profile ─────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (context, state) =>
                const OrderHistoryScreen(showActive: true),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) =>
                const OrderHistoryScreen(showActive: false),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Menu Detail
      GoRoute(
        path: AppRoutes.menuDetail,
        builder: (context, state) {
          final menuId = state.pathParameters['id']!;
          return MenuDetailScreen(menuId: menuId);
        },
      ),

      // Menu List
      GoRoute(
        path: AppRoutes.menuList,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return MenuListScreen(category: category);
        },
      ),

      // Cart (butuh login)
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),

      // Checkout (butuh login)
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Order Tracking (butuh login)
      GoRoute(
        path: AppRoutes.orderTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),

      // Order Pickup (butuh login)
      GoRoute(
        path: AppRoutes.orderPickup,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderPickupScreen(orderId: orderId);
        },
      ),
    ],
  );
}
