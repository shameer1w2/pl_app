// lib/widgets/lift_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/lift_model.dart';

class LiftCard extends StatelessWidget {
  final LiftModel lift;
  final VoidCallback onTap;
  final bool showFeedbackStatus;

  const LiftCard({
    super.key,
    required this.lift,
    required this.onTap,
    this.showFeedbackStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy · HH:mm').format(lift.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Exercise icon ───────────────────────────────────────────
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppTheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // ── Lift info ───────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lift.exercise,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _statBadge('${lift.weight}kg'),
                          const SizedBox(width: 8),
                          _statBadge('${lift.reps} reps'),
                          const SizedBox(width: 8),
                          _statBadge('RPE ${lift.rpe}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Feedback status ──────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    _statusLabel(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _statusLabel() {
    final status = lift.hasFeedback ? 'Reviewed' : (showFeedbackStatus ? 'Pending' : 'No feedback');
    final color = lift.hasFeedback ? AppTheme.success : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
