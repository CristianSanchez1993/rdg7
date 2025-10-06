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

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    
    final Map<String, dynamic> userDTO =
        (json['userDTO'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> courtDTO =
        (json['courtDTO'] as Map?)?.cast<String, dynamic>() ?? {};

    final int userId = _toInt(userDTO['id'] ?? json['user_id']);
    final int courtId = _toInt(courtDTO['id'] ?? json['court_id']);

    return ReservationModel(
      id: _toInt(json['id']),
      courtId: courtId,
      userId: userId,
      startAt: _toDate(json['startAt'] ?? json['start_at']),
      endAt: _toDate(
        json['endAt'] ?? json['end_at'],
        fallback: DateTime.now().add(const Duration(hours: 1)),
      ),
      statusCode: (json['statusCode'] ?? json['status_code'] ?? 'PENDING')
          .toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courtDTO': {'id': courtId},
    'userDTO': {'id': userId},
    'startAt': startAt.toIso8601String(),
    'endAt': endAt.toIso8601String(),
    'statusCode': statusCode,
    'notes': notes,
  };

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _toDate(dynamic value, {DateTime? fallback}) {
    if (value == null) return fallback ?? DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return fallback ?? DateTime.now();
      }
    }
    return fallback ?? DateTime.now();
  }
}
