class Office {
  final String id;
  final String name;
  final double lat;
  final double lng;

  Office({required this.id, required this.name, required this.lat, required this.lng});

  factory Office.fromMap(String id, Map<String, dynamic> map) {
    return Office(
      id: id,
      name: map['name'],
      lat: map['lat'],
      lng: map['lng'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'lat': lat,
    'lng': lng,
  };
}
