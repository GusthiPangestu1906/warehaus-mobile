class Stock {
  final String id;
  final int shelfId;
  final String productId;
  final int quantity;
  final String? shelfCode;
  final int? zoneId;
  final String? zoneCode;
  final String? zoneName;
  final int? aisle;
  final String? locationName;
  final int? shelfCapacity;
  final int? shelfCurrentVolume;
  final int? shelfAvailableCapacity;
  final String? qrCodePath;

  Stock({
    required this.id,
    required this.shelfId,
    required this.productId,
    required this.quantity,
    this.shelfCode,
    this.zoneId,
    this.zoneCode,
    this.zoneName,
    this.aisle,
    this.locationName,
    this.shelfCapacity,
    this.shelfCurrentVolume,
    this.shelfAvailableCapacity,
    this.qrCodePath,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    final shelfJson = json['shelf'] as Map<String, dynamic>?;
    return Stock(
      id: json['id']?.toString() ?? '',
      shelfId: json['shelfId'] as int? ?? 0,
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      shelfCode: shelfJson?['shelfCode']?.toString() ?? json['shelfCode']?.toString(),
      zoneId: json['zoneId'] as int?,
      zoneCode: json['zoneCode'] as String?,
      zoneName: json['zoneName'] as String?,
      aisle: shelfJson?['aisle'] as int? ?? json['aisle'] as int?,
      locationName: json['locationName'] as String?,
      shelfCapacity: shelfJson?['capacity'] as int? ?? json['shelfCapacity'] as int?,
      shelfCurrentVolume: shelfJson?['currentVolume'] as int? ?? json['shelfCurrentVolume'] as int?,
      shelfAvailableCapacity: json['shelfAvailableCapacity'] as int?,
      qrCodePath: shelfJson?['qrCodePath']?.toString() ?? json['qrCodePath']?.toString(),
    );
  }
}
