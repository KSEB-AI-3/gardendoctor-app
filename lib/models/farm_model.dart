class Farm {
  final int gardenUniqueId;
  final String? operator;
  final String? farmName;   // name → farmName 변경
  final String? roadNameAddress;
  final String? lotNumberAddress;
  final String? facilities;
  final bool? available;
  final String? contact;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  Farm({
    required this.gardenUniqueId,
    this.operator,
    this.farmName,            // name → farmName
    this.roadNameAddress,
    this.lotNumberAddress,
    this.facilities,
    this.available,
    this.contact,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      gardenUniqueId: json['gardenUniqueId'],
      operator: json['operator'],
      farmName: json['farmName'],              // name → farmName
      roadNameAddress: json['roadNameAddress'],
      lotNumberAddress: json['lotNumberAddress'],
      facilities: json['facilities'],
      available: json['available'],
      contact: json['contact'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
