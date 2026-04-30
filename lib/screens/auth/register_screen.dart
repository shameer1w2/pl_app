// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';

import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _coachIdCtrl = TextEditingController();

  String _role = UserRoles.client;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _coachIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          role: _role,
          coachId: _role == UserRoles.client ? _coachIdCtrl.text.trim() : null,
        );

    final authState = ref.read(authProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${authState.error}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                IconButton(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                const Text(
                  'Join LiftLog.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Create an account to start your journey.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your name' : null,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your email' : null,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 8 ? 'Min 8 characters' : null,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
                const Text('I am a...',
                        style: TextStyle(fontWeight: FontWeight.w600))
                    .animate()
                    .fadeIn(delay: 600.ms),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _roleChip(UserRoles.coach, 'Coach', Icons.sports),
                    const SizedBox(width: 12),
                    _roleChip(UserRoles.client, 'Athlete', Icons.fitness_center),
                  ],
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                if (_role == UserRoles.client) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _coachIdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Coach ID (from your coach)',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => _role == UserRoles.client &&
                            (v == null || v.isEmpty)
                        ? 'Enter your coach ID'
                        : null,
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                ],
                const SizedBox(height: 40),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('CREATE ACCOUNT'),
                      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(color: AppTheme.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : AppTheme.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
