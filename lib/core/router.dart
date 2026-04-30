// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/client/client_home_screen.dart';
import '../screens/client/upload_lift_screen.dart';
import '../screens/client/lift_detail_screen.dart';
import '../screens/coach/coach_home_screen.dart';
import '../screens/coach/client_lift_list_screen.dart';
import '../screens/coach/coach_lift_detail_screen.dart';
import 'constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Notify GoRouter when auth state changes WITHOUT recreating the router.
  // Using ref.watch here would destroy and rebuild GoRouter on every auth
  // change, resetting navigation back to the initial route (the login bug).
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) {
    refreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final user = authState.valueOrNull;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (authState.isLoading) return null;

      if (user == null) {
        return (state.matchedLocation == AppRoutes.login ||
                state.matchedLocation == AppRoutes.register)
            ? null
            : AppRoutes.login;
      }

      if (isOnAuth) {
        return user.isCoach ? AppRoutes.coachHome : AppRoutes.clientHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Client routes ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.clientHome,
        builder: (_, __) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.uploadLift,
        builder: (_, __) => const UploadLiftScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientLiftDetail,
        builder: (_, state) =>
            LiftDetailScreen(liftId: state.pathParameters['id']!),
      ),

      // ── Coach routes ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.coachHome,
        builder: (_, __) => const CoachHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientLiftList,
        builder: (_, state) =>
            ClientLiftListScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: AppRoutes.coachLiftDetail,
        builder: (_, state) =>
            CoachLiftDetailScreen(liftId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
