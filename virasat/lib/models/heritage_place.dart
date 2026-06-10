class HeritagePlace {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String description;
  final String? source;

  const HeritagePlace({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.description,
    this.source,
  });

  factory HeritagePlace.fromJson(Map<String, dynamic> json) {
    return HeritagePlace(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'distance_km': distanceKm,
        'description': description,
        'source': source,
      };
}
