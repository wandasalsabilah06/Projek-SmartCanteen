import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
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

  /// Route yang WAJIB login — prefix-match
  static const _protected = [
    '/cart',
    '/checkout',
    '/orders',
    '/history',
    '/profile',
    '/order/',
  ];

  static bool _needsAuth(String loc) =>
      _protected.any((p) => loc.startsWith(p));

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Halaman publik — tidak perlu cek auth
      if (loc == AppRoutes.splash || loc == AppRoutes.login || loc == AppRoutes.register) return null;

      if (_needsAuth(loc)) {
        // Gunakan context GoRouter (aman, tidak null)
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (!auth.isAuthenticated) {
          final encoded = Uri.encodeComponent(loc);
          return '${AppRoutes.login}?from=$encoded';
        }
      }

      return null;
    },

    routes: [
      // Splash
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),

      // Login
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),

      // Register
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),

      // ── Shell: Home / Orders / History / Profile ─────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: AppRoutes.orders,
            builder: (context, state) => const OrderHistoryScreen(showActive: true),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const OrderHistoryScreen(showActive: false),
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
        builder: (context, state) =>
            MenuDetailScreen(menuId: state.pathParameters['id']!),
      ),

      // Menu List
      GoRoute(
        path: AppRoutes.menuList,
        builder: (context, state) =>
            MenuListScreen(category: state.uri.queryParameters['category']),
      ),

      // Cart (protected)
      GoRoute(path: AppRoutes.cart, builder: (context, state) => const CartScreen()),

      // Checkout (protected)
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Order Tracking (protected)
      GoRoute(
        path: AppRoutes.orderTracking,
        builder: (context, state) =>
            OrderTrackingScreen(orderId: state.pathParameters['id']!),
      ),

      // Order Pickup (protected)
      GoRoute(
        path: AppRoutes.orderPickup,
        builder: (context, state) =>
            OrderPickupScreen(orderId: state.pathParameters['id']!),
      ),
    ],
  );
}
