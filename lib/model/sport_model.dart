class SportModel {
  final int? id;
  final String name;

  SportModel({
    this.id,
    required this.name,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) => SportModel(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
      };

  SportModel copyWith({int? id, String? name}) =>
      SportModel(id: id ?? this.id, name: name ?? this.name);
}
