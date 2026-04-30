// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';

import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );

    final authState = ref.read(authProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${authState.error}'),
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
                const SizedBox(height: 64),
                const Icon(Icons.fitness_center,
                        size: 56, color: AppTheme.primary)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),
                const Text(
                  'Welcome back.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your performance dashboard.',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 48),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 40),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('LOG IN'),
                      ).animate().fadeIn(delay: 1.seconds).scale(curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: AppTheme.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
