// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 80,
              color: AppTheme.primary,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1200.ms, color: Colors.white24)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.1, 1.1),
                  duration: 600.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 24),
            const Text(
              'LiftLog Coach',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: 2.0,
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            Text(
              'Precision Performance Tracking',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.7),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            const SizedBox(height: 64),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primary,
              ),
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}
