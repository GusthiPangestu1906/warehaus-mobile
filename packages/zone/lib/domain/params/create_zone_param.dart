class CreateZoneParam {
  final String zoneCode;
  final String zoneName;
  final String? description;
  final int categoryId;
  final int totalAisle;
  final int shelfPerAisle;
  final int capacityPerShelf;

  CreateZoneParam({
    required this.zoneCode,
    required this.zoneName,
    this.description,
    required this.categoryId,
    required this.totalAisle,
    required this.shelfPerAisle,
    required this.capacityPerShelf,
  });

  factory CreateZoneParam.fromJson(Map<String, dynamic> json) {
    return CreateZoneParam(
      zoneCode: json['zoneCode'] as String? ?? '',
      zoneName: json['zoneName'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: (json['categoryId'] ?? json['category_id']) as int? ?? 0,
      totalAisle: (json['totalAisle'] ?? json['total_aisle']) as int? ?? 0,
      shelfPerAisle:
          (json['shelfPerAisle'] ?? json['shelf_per_aisle']) as int? ?? 0,
      capacityPerShelf: (json['capacityPerShelf'] ??
              json['capacity_per_shelf']) as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneCode': zoneCode,
      'zoneName': zoneName,
      'description': description,
      'categoryId': categoryId,
      'totalAisle': totalAisle,
      'shelfPerAisle': shelfPerAisle,
      'capacityPerShelf': capacityPerShelf,
    };
  }
}