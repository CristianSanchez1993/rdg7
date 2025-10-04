class CourtModel {
  final int id;
  final String name;
  final String location;
  final int sportId;
  final double pricePerHour;
  final bool isActive;

  CourtModel({
    required this.id,
    required this.name,
    required this.location,
    required this.sportId,
    required this.pricePerHour,
    required this.isActive,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) => CourtModel(
    id: json['id'] as int,
    name: json['name'] as String,
    location: json['location'] as String,
    sportId: json['sport id'] as int,
    pricePerHour: (json['price per hour'] as num).toDouble(),
    isActive: json['is active'] == 1 || json['is active'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'sport id': sportId,
    'price per hour': pricePerHour,
    'is active': isActive,
  };
}
