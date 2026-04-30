// lib/providers/app_providers.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/lift_model.dart';
import '../services/auth_service.dart';
import '../services/lift_service.dart';
import '../services/storage_service.dart';

// ─── Appwrite Client (singleton) ──────────────────────────────────────────────

final appwriteClientProvider = Provider<Client>((ref) {
  return Client()
    ..setEndpoint(AppwriteConstants.endpoint)
    ..setProject(AppwriteConstants.projectId)
    ..setSelfSigned(status: true); // remove in production
});

// ─── Services ─────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(appwriteClientProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(appwriteClientProvider));
});

final liftServiceProvider = Provider<LiftService>((ref) {
  return LiftService(
    ref.watch(appwriteClientProvider),
    ref.watch(storageServiceProvider),
  );
});

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    try {
      final authService = ref.read(authServiceProvider);
      final loggedIn = await authService.isLoggedIn();
      if (!loggedIn) return null;
      return authService.getCurrentUser();
    } catch (e, stack) {
      debugPrint('AuthNotifier initialization error: $e');
      debugPrint(stack.toString());
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).login(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? coachId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).register(
            name: name,
            email: email,
            password: password,
            role: role,
            coachId: coachId,
          ),
    );
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

// ─── Client Lifts ─────────────────────────────────────────────────────────────

final clientLiftsProvider =
    FutureProvider.family<List<LiftModel>, String>((ref, clientId) async {
  return ref.read(liftServiceProvider).getLiftsForClient(clientId);
});

// ─── Clients for a coach ──────────────────────────────────────────────────────

final coachClientsProvider =
    FutureProvider.family<List<UserModel>, String>((ref, coachId) async {
  return ref.read(authServiceProvider).getClientsForCoach(coachId);
});

// ─── Single lift detail ───────────────────────────────────────────────────────

final liftDetailProvider =
    FutureProvider.family<LiftModel, String>((ref, liftId) async {
  return ref.read(liftServiceProvider).getLiftById(liftId);
});
