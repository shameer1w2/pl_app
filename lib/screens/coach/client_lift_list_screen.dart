import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/lift_card.dart';

class ClientLiftListScreen extends ConsumerWidget {
  final String clientId;
  const ClientLiftListScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liftsAsync = ref.watch(clientLiftsProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Athlete History')),
      body: liftsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lifts) {
          if (lifts.isEmpty) {
            return Center(
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
                  const Text('This athlete hasn\'t submitted any data.',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ).animate().fadeIn(delay: 200.ms),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lifts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => LiftCard(
              lift: lifts[i],
              showFeedbackStatus: true,
              onTap: () => context.push('/coach/lift/${lifts[i].id}'),
            )
                .animate()
                .fadeIn(delay: (i * 50).ms)
                .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
          );
        },
      ),
    );
  }
}
