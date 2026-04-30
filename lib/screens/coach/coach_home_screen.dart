// lib/screens/coach/coach_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';

import 'package:flutter_animate/flutter_animate.dart';

class CoachHomeScreen extends ConsumerWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final clientsAsync = ref.watch(coachClientsProvider(user.id));

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
                    'Coach ${user.name.split(' ').first}',
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

              // ── Share ID Card ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SHARE YOUR COACH ID',
                                style: TextStyle(
                                  color: AppTheme.textSecondary.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user.id,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: user.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Coach ID copied!'),
                                  backgroundColor: AppTheme.success,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded,
                                color: AppTheme.primary, size: 20),
                            tooltip: 'Copy ID',
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, 32, 20, 16),
                  child: Text(
                    'Your Athletes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              // ── Athletes List ─────────────────────────────────────────
              clientsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primary)),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error loading athletes: $e')),
                ),
                data: (clients) {
                  if (clients.isEmpty) {
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
                              child: const Icon(Icons.group_off_rounded,
                                  size: 48, color: AppTheme.textSecondary),
                            ).animate().scale(duration: 500.ms),
                            const SizedBox(height: 24),
                            const Text(
                              'No athletes yet',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Share your ID to start coaching.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final client = clients[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.textSecondary.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primary,
                                      AppTheme.primary.withOpacity(0.6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    client.name[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              title: Text(
                                client.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                client.email,
                                style: TextStyle(
                                    color: AppTheme.textSecondary.withOpacity(0.7),
                                    fontSize: 12),
                              ),
                              trailing: Icon(Icons.chevron_right_rounded,
                                  color: AppTheme.textSecondary.withOpacity(0.4)),
                              onTap: () => context
                                  .push('/coach/client/${client.id}'),
                            ),
                          );
                        },
                        childCount: clients.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
