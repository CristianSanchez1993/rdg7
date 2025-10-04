class ReservationModel {
  final int id;
  final int courtId;
  final int userId;
  final DateTime startAt;
  final DateTime endAt;
  final String statusCode;
  final String? notes;

  ReservationModel({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.startAt,
    required this.endAt,
    required this.statusCode,
    this.notes,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      ReservationModel(
        id: json['id'] as int,
        courtId: json['court_id'] as int,
        userId: json['user_id'] as int,
        startAt: DateTime.parse(json['start_at'] as String),
        endAt: DateTime.parse(json['end_at'] as String),
        statusCode: json['status_code'] as String,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'court_id': courtId,
    'user_id': userId,
    'start_at': startAt.toIso8601String(),
    'end_at': endAt.toIso8601String(),
    'status_code': statusCode,
    'notes': notes,
  };
}
