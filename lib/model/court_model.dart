class SportMini {
  final int? id;
  final String? name;

  const SportMini({this.id, this.name});

  factory SportMini.fromJson(Map<String, dynamic> json) => SportMini(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
      };
}

class CourtModel {
  final int? id; // puede ser null al crear (backend asigna)
  final String name;
  final String location;
  final SportMini? sportDTO; // el backend espera sportDTO
  final double pricePerHour;
  final bool isActive;

  /// Acepta sportDTO o sportId; serializa como sportDTO
  CourtModel({
    this.id,
    required this.name,
    required this.location,
    SportMini? sportDTO,
    int? sportId,
    required this.pricePerHour,
    required this.isActive,
  }) : sportDTO = sportDTO ?? (sportId != null ? SportMini(id: sportId) : null);

  int get sportId => sportDTO?.id ?? 0;

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    final dynamic priceRaw = json['pricePerHour'];
    final double price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0.0;

    final dynamic activeRaw = json['isActive'];
    final bool active;
    if (activeRaw is bool) {
      active = activeRaw;
    } else if (activeRaw is num) {
      active = activeRaw != 0;
    } else if (activeRaw is String) {
      final String s = activeRaw.toLowerCase();
      active = (s == 'true' || s == '1');
    } else {
      active = false;
    }

    final SportMini? sport =
        json['sportDTO'] is Map<String, dynamic>
            ? SportMini.fromJson(json['sportDTO'] as Map<String, dynamic>)
            : null;

    return CourtModel(
      id: (json['id'] as num?)?.toInt(), // si backend no lo manda, queda null
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      sportDTO: sport,
      pricePerHour: price,
      isActive: active,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id, // importante para update-by-id
        'name': name,
        'location': location,
        'sportDTO': sportDTO?.toJson(),
        'pricePerHour': pricePerHour,
        'isActive': isActive,
      };

  CourtModel copyWith({
    int? id,
    String? name,
    String? location,
    int? sportId,
    SportMini? sportDTO,
    double? pricePerHour,
    bool? isActive,
  }) =>
      CourtModel(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        sportDTO: sportDTO ?? (sportId != null ? SportMini(id: sportId) : this.sportDTO),
        pricePerHour: pricePerHour ?? this.pricePerHour,
        isActive: isActive ?? this.isActive,
      );
}
