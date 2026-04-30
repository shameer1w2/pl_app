// lib/services/lift_service.dart
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import '../core/constants.dart';
import '../models/lift_model.dart';
import 'storage_service.dart';

class LiftService {
  final Databases _databases;
  final StorageService _storageService;

  LiftService(Client client, this._storageService)
      : _databases = Databases(client);

  // ─── Upload a new lift (video + metadata) ─────────────────────────────────

  Future<LiftModel> uploadLift({
    required String clientId,
    required String coachId,
    required String exercise,
    required double weight,
    required int reps,
    required double rpe,
    required String notes,
    required File videoFile,
  }) async {
    // Upload video, get file ID back
    final videoFileId = await _storageService.uploadLiftVideo(videoFile);

    // Save document to DB
    final docId = ID.unique();
    final now = DateTime.now();

    final data = {
      'client_id': clientId,
      'coach_id': coachId,
      'exercise': exercise,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'notes': notes,
      'video_url': videoFileId,
      'created_at': now.toIso8601String(),
    };

    final doc = await _databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.liftsCollectionId,
      documentId: docId,
      data: data,
    );

    return LiftModel.fromMap(doc.data..['\$id'] = doc.$id);
  }

  // ─── Fetch lifts for a client ─────────────────────────────────────────────

  Future<List<LiftModel>> getLiftsForClient(String clientId) async {
    final result = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.liftsCollectionId,
      queries: [
        Query.equal('client_id', clientId),
        Query.orderDesc('created_at'),
      ],
    );

    return result.documents
        .map((doc) => LiftModel.fromMap(doc.data..['\$id'] = doc.$id))
        .toList();
  }

  // ─── Fetch a single lift by ID ────────────────────────────────────────────

  Future<LiftModel> getLiftById(String liftId) async {
    final doc = await _databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.liftsCollectionId,
      documentId: liftId,
    );

    return LiftModel.fromMap(doc.data..['\$id'] = doc.$id);
  }

  // ─── Coach saves feedback ─────────────────────────────────────────────────

  Future<LiftModel> saveFeedback({
    required String liftId,
    required String feedback,
  }) async {
    final doc = await _databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.liftsCollectionId,
      documentId: liftId,
      data: {'feedback': feedback},
    );

    return LiftModel.fromMap(doc.data..['\$id'] = doc.$id);
  }
}
