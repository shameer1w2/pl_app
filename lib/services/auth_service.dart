// lib/services/auth_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Account _account;
  final Databases _databases;

  AuthService(Client client)
      : _account = Account(client),
        _databases = Databases(client);

  // ─── Register ────────────────────────────────────────────────────────────

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? coachId,
  }) async {
    // 1. Create Appwrite auth account
    final appwrite_models.User appwriteUser = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );

    // 2. Create email session (log them in right after register)
    await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    // 3. Save user document in DB
    final user = UserModel(
      id: appwriteUser.$id,
      name: name,
      email: email,
      role: role,
      coachId: coachId,
      createdAt: DateTime.now(),
    );

    await _databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollectionId,
      documentId: appwriteUser.$id,
      data: user.toMap(),
    );

    return user;
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    return getCurrentUser();
  }

  // ─── Get current user ─────────────────────────────────────────────────────

  Future<UserModel> getCurrentUser() async {
    final appwrite_models.User appwriteUser = await _account.get();

    final doc = await _databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollectionId,
      documentId: appwriteUser.$id,
    );

    return UserModel.fromMap(doc.data..['\$id'] = doc.$id);
  }

  // ─── Check session ────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    try {
      await _account.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }

  // ─── Fetch clients for a coach ────────────────────────────────────────────

  Future<List<UserModel>> getClientsForCoach(String coachId) async {
    final result = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollectionId,
      queries: [
        Query.equal('coach_id', coachId),
        Query.equal('role', 'client'),
      ],
    );

    return result.documents
        .map((doc) => UserModel.fromMap(doc.data..['\$id'] = doc.$id))
        .toList();
  }
}
