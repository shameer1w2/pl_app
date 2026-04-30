// lib/models/lift_model.dart

class LiftModel {
  final String id;
  final String clientId;
  final String coachId;
  final String exercise;
  final double weight;
  final int reps;
  final double rpe;
  final String notes;
  final String videoUrl;
  final String? feedback;
  final DateTime createdAt;

  const LiftModel({
    required this.id,
    required this.clientId,
    required this.coachId,
    required this.exercise,
    required this.weight,
    required this.reps,
    required this.rpe,
    required this.notes,
    required this.videoUrl,
    this.feedback,
    required this.createdAt,
  });

  bool get hasFeedback => feedback != null && feedback!.isNotEmpty;

  factory LiftModel.fromMap(Map<String, dynamic> map) {
    return LiftModel(
      id: map['\$id'] as String,
      clientId: map['client_id'] as String,
      coachId: map['coach_id'] as String,
      exercise: map['exercise'] as String,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      rpe: (map['rpe'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
      videoUrl: map['video_url'] as String,
      feedback: map['feedback'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'coach_id': coachId,
      'exercise': exercise,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'notes': notes,
      'video_url': videoUrl,
      if (feedback != null) 'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LiftModel copyWith({
    String? id,
    String? clientId,
    String? coachId,
    String? exercise,
    double? weight,
    int? reps,
    double? rpe,
    String? notes,
    String? videoUrl,
    String? feedback,
    DateTime? createdAt,
  }) {
    return LiftModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      coachId: coachId ?? this.coachId,
      exercise: exercise ?? this.exercise,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      videoUrl: videoUrl ?? this.videoUrl,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
