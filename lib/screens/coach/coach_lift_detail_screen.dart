// lib/screens/coach/coach_lift_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';

import 'package:flutter_animate/flutter_animate.dart';

class CoachLiftDetailScreen extends ConsumerStatefulWidget {
  final String liftId;
  const CoachLiftDetailScreen({super.key, required this.liftId});

  @override
  ConsumerState<CoachLiftDetailScreen> createState() =>
      _CoachLiftDetailScreenState();
}

class _CoachLiftDetailScreenState
    extends ConsumerState<CoachLiftDetailScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _initStarted = false;
  bool _playing = false;
  bool _saving = false;

  late TextEditingController _feedbackCtrl;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _initVideo(String fileId) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final videoFile = await storageService.downloadVideo(fileId);
      
      _videoController = VideoPlayerController.file(videoFile);
      
      await _videoController!.initialize();
      _videoController!.addListener(() {
        if (mounted) {
          final isPlaying = _videoController!.value.isPlaying;
          if (_playing != isPlaying) {
            setState(() => _playing = isPlaying);
          }
        }
      });
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

  Future<void> _saveFeedback() async {
    final feedback = _feedbackCtrl.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write some feedback first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(liftServiceProvider).saveFeedback(
            liftId: widget.liftId,
            feedback: feedback,
          );
      ref.invalidate(liftDetailProvider(widget.liftId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback sent to athlete ✅'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liftAsync = ref.watch(liftDetailProvider(widget.liftId));

    return Scaffold(
      appBar: AppBar(title: const Text('Review Analysis')),
      body: liftAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lift) {
          if (_feedbackCtrl.text.isEmpty && lift.hasFeedback) {
            _feedbackCtrl.text = lift.feedback!;
          }

          if (!_initStarted) {
            _initStarted = true;
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
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black87],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white70),
                                        onPressed: () {
                                          final pos = _videoController!.value.position;
                                          _videoController!.seekTo(pos - const Duration(seconds: 10));
                                        },
                                      ),
                                      IconButton(
                                        iconSize: 48,
                                        color: Colors.white,
                                        icon: Icon(_playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
                                        onPressed: () {
                                          setState(() {
                                            _playing ? _videoController!.pause() : _videoController!.play();
                                            _playing = !_playing;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white70),
                                        onPressed: () {
                                          final pos = _videoController!.value.position;
                                          _videoController!.seekTo(pos + const Duration(seconds: 10));
                                        },
                                      ),
                                    ],
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
                              child: CircularProgressIndicator(color: AppTheme.primary),
                            ),
                          ),
                  ),
                ).animate().fadeIn().scale(duration: 400.ms),

                const SizedBox(height: 32),

                // ── Lift stats ──────────────────────────────────────────
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      lift.notes,
                      style: TextStyle(
                          color: AppTheme.textPrimary.withOpacity(0.8),
                          height: 1.5),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // ── Feedback Entry ────────────────────────────────────────
                const Text('COACH FEEDBACK',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppTheme.textSecondary))
                    .animate()
                    .fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Provide technical cues and performance feedback...',
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                _saving
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary))
                    : ElevatedButton.icon(
                        onPressed: _saveFeedback,
                        icon: const Icon(Icons.send_rounded),
                        label: Text(
                          lift.hasFeedback ? 'UPDATE FEEDBACK' : 'SEND FEEDBACK',
                        ),
                      ).animate().fadeIn(delay: 600.ms).scale(curve: Curves.easeOutBack),
                
                const SizedBox(height: 64),
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
