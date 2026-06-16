class Shelf {
  final String id;
  final String shelfCode;
  final int aisle;
  final int capacity;
  final int currentVolume;
  final String qrCodePath;

  Shelf({
    required this.id,
    required this.shelfCode,
    required this.aisle,
    required this.capacity,
    required this.currentVolume,
    required this.qrCodePath,
  });

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      id: (json['shelfId'] ?? json['id'])?.toString() ?? '',
      shelfCode: (json['shelfCode'] ?? json['binCode']) as String? ?? '',
      aisle: json['aisle'] as int? ?? 0,
      capacity: json['capacity'] as int? ?? 0,
      currentVolume: json['currentVolume'] as int? ?? 0,
      qrCodePath: json['qrCodePath'] as String? ?? '',
    );
  }
}
