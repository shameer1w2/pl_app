// lib/services/storage_service.dart
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:video_compress/video_compress.dart';
import '../core/constants.dart';

class StorageService {
  final Storage _storage;

  StorageService(Client client) : _storage = Storage(client);

  // ─── Compress & upload video ───────────────────────────────────────────────

  Future<String> uploadLiftVideo(File videoFile) async {
    // 1. Compress
    final compressedInfo = await VideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );

    if (compressedInfo == null || compressedInfo.file == null) {
      throw Exception('Video compression failed');
    }

    final compressedFile = compressedInfo.file!;

    // 2. Upload to Appwrite Storage
    final fileId = ID.unique();
    await _storage.createFile(
      bucketId: AppwriteConstants.liftVideosBucketId,
      fileId: fileId,
      file: InputFile.fromPath(
        path: compressedFile.path,
        filename: '$fileId.mp4',
        contentType: 'video/mp4',
      ),
    );

    // 3. Return the file ID (used as video_url in DB)
    return fileId;
  }

  // ─── Download video to local temp file (authenticated via SDK session) ────

  Future<File> downloadVideo(String fileId) async {
    final bytes = await _storage.getFileDownload(
      bucketId: AppwriteConstants.liftVideosBucketId,
      fileId: fileId,
    );

    final file = File('${Directory.systemTemp.path}/liftlog_$fileId.mp4');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ─── Get video stream URL (kept for reference, requires public bucket) ────

  String getVideoStreamUrl(String fileId) {
    return '${AppwriteConstants.endpoint}/storage/buckets/'
        '${AppwriteConstants.liftVideosBucketId}/files/$fileId/view'
        '?project=${AppwriteConstants.projectId}';
  }

  // ─── Delete video ─────────────────────────────────────────────────────────

  Future<void> deleteVideo(String fileId) async {
    await _storage.deleteFile(
      bucketId: AppwriteConstants.liftVideosBucketId,
      fileId: fileId,
    );
  }
}
