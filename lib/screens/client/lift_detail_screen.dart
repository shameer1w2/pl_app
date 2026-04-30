// lib/screens/client/lift_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../services/storage_service.dart';
import '../../widgets/lift_stat_row.dart';

import 'package:flutter_animate/flutter_animate.dart';

class LiftDetailScreen extends ConsumerStatefulWidget {
  final String liftId;
  const LiftDetailScreen({super.key, required this.liftId});

  @override
  ConsumerState<LiftDetailScreen> createState() => _LiftDetailScreenState();
}

class _LiftDetailScreenState extends ConsumerState<LiftDetailScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _playing = false;

  Future<void> _initVideo(String fileId) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final url = storageService.getVideoStreamUrl(fileId);

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          'X-Appwrite-Project': AppwriteConstants.projectId,
        },
      );
      
      await _videoController!.initialize();
      if (mounted) setState(() => _videoInitialized = true);
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load video: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liftAsync = ref.watch(liftDetailProvider(widget.liftId));

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: liftAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lift) {
          if (!_videoInitialized && _videoController == null) {
            _initVideo(lift.videoUrl);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Video Player ─────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _videoInitialized
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                              if (!_playing)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _videoController!.play();
                                      _playing = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(Icons.play_arrow_rounded,
                                        size: 48, color: Colors.white),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black54],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _playing ? _videoController!.pause() : _videoController!.play();
                                        _playing = !_playing;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: 220,
                            width: double.infinity,
                            color: AppTheme.card,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primary),
                            ),
                          ),
                  ),
                ).animate().fadeIn().scale(duration: 400.ms),

                const SizedBox(height: 32),

                // ── Header & Primary Stats ────────────────────────────────
                Text(
                  lift.exercise.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    _expandedStat('Weight', '${lift.weight}kg'),
                    const SizedBox(width: 12),
                    _expandedStat('Reps', '${lift.reps}'),
                    const SizedBox(width: 12),
                    _expandedStat('RPE', '${lift.rpe}'),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                if (lift.notes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('ATHLETE NOTES',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    lift.notes,
                    style: TextStyle(
                        color: AppTheme.textPrimary.withOpacity(0.8),
                        height: 1.5),
                  ),
                ],

                const SizedBox(height: 40),

                // ── Coach Feedback Section ────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: lift.hasFeedback 
                        ? AppTheme.primary.withOpacity(0.05)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: lift.hasFeedback 
                          ? AppTheme.primary.withOpacity(0.2)
                          : AppTheme.textSecondary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            lift.hasFeedback ? Icons.comment_rounded : Icons.pending_rounded,
                            color: lift.hasFeedback ? AppTheme.primary : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            lift.hasFeedback ? 'COACH FEEDBACK' : 'WAITING FOR COACH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: lift.hasFeedback ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      lift.hasFeedback
                          ? Text(
                              lift.feedback!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const Text(
                              'Your coach will review your form and provide guidance here shortly.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _expandedStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
