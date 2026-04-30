// lib/screens/client/upload_lift_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';

class UploadLiftScreen extends ConsumerStatefulWidget {
  const UploadLiftScreen({super.key});

  @override
  ConsumerState<UploadLiftScreen> createState() => _UploadLiftScreenState();
}

class _UploadLiftScreenState extends ConsumerState<UploadLiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _rpeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedExercise = Exercises.list.first;
  File? _videoFile;
  VideoPlayerController? _videoController;
  bool _uploading = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    _rpeCtrl.dispose();
    _notesCtrl.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: source);
    if (picked == null) return;

    final file = File(picked.path);
    final controller = VideoPlayerController.file(file);
    await controller.initialize();

    setState(() {
      _videoFile = file;
      _videoController?.dispose();
      _videoController = controller;
    });
  }

  Future<void> _upload() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value!;
    if (user.coachId == null || user.coachId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No coach assigned. Ask your coach for their ID.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _uploading = true);

    try {
      await ref.read(liftServiceProvider).uploadLift(
            clientId: user.id,
            coachId: user.coachId!,
            exercise: _selectedExercise,
            weight: double.parse(_weightCtrl.text.trim()),
            reps: int.parse(_repsCtrl.text.trim()),
            rpe: double.parse(_rpeCtrl.text.trim()),
            notes: _notesCtrl.text.trim(),
            videoFile: _videoFile!,
          );

      ref.invalidate(clientLiftsProvider(user.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lift uploaded! 🎉'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Submission'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Video Preview ─────────────────────────────────────────────
              _videoController != null && _videoController!.value.isInitialized
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 20),
                                  onPressed: _showSourcePicker,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOut)
                  : GestureDetector(
                      onTap: () => _showSourcePicker(),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.videocam_rounded,
                                  size: 40, color: AppTheme.primary),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(
                                duration: 2.seconds, color: Colors.white10),
                            const SizedBox(height: 16),
                            const Text(
                              'Record or Upload Video',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MP4 or MOV preferred',
                              style: TextStyle(
                                  color: AppTheme.textSecondary.withOpacity(0.5),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),

              const SizedBox(height: 32),
              const Text('EXERCISE DETAILS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppTheme.textSecondary))
                  .animate()
                  .fadeIn(delay: 200.ms),
              const SizedBox(height: 16),

              // ── Exercise dropdown ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedExercise,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primary),
                    dropdownColor: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    items: Exercises.list
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedExercise = v!),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // ── Stats row ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Weight',
                        suffixText: 'kg',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _repsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Reps'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rpeCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'RPE'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Req';
                        final n = double.tryParse(v);
                        if (n == null || n < 1 || n > 10) return '1-10';
                        return null;
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 20),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add notes about this set...',
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 48),
              _uploading
                  ? Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                              color: AppTheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'PREPARING VIDEO...',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _upload,
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text('SUBMIT LIFT'),
                    ).animate().fadeIn(delay: 600.ms).scale(curve: Curves.easeOutBack),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Video Source',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _sourceOption(
                  icon: Icons.videocam_rounded,
                  label: 'Camera',
                  color: AppTheme.primary,
                  onTap: () {
                    context.pop();
                    _pickVideo(ImageSource.camera);
                  },
                ),
                const SizedBox(width: 16),
                _sourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: Colors.blue,
                  onTap: () {
                    context.pop();
                    _pickVideo(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
