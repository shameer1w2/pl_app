// lib/screens/client/client_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/lift_card.dart';

import 'package:flutter_animate/flutter_animate.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final liftsAsync = ref.watch(clientLiftsProvider(user.id));

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.2,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Hey, ${user.name.split(' ').first} 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                    ),
                  ),
                ],
              ),

              // ── Main Content ──────────────────────────────────────────
              liftsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primary)),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error loading lifts: $e')),
                ),
                data: (lifts) {
                  if (lifts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.card,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.videocam_off_rounded,
                                  size: 48, color: AppTheme.textSecondary),
                            ).animate().scale(duration: 500.ms),
                            const SizedBox(height: 24),
                            const Text(
                              'No lifts uploaded yet',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your journey starts with your first upload.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          return LiftCard(
                            lift: lifts[i],
                            onTap: () =>
                                context.push('/client/lift/${lifts[i].id}'),
                          ).animate().fadeIn(delay: (i * 50).ms).slideX(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOut);
                        },
                        childCount: lifts.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.uploadLift),
            backgroundColor: AppTheme.primary,
            elevation: 8,
            icon: const Icon(Icons.videocam_rounded, color: Colors.white),
            label: const Text(
              'NEW LIFT',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8),
            ),
          ).animate().fadeIn(delay: 1.seconds).scale(curve: Curves.easeOutBack),
        );
      },
    );
  }
}
