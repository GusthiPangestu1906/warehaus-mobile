import 'package:product/domain/entities/stock.dart';

class StockModel extends Stock {
  StockModel({
    required super.id,
    required super.shelfId,
    required super.productId,
    required super.quantity,
    super.shelfCode,
    super.zoneId,
    super.zoneCode,
    super.zoneName,
    super.aisle,
    super.locationName,
    super.shelfCapacity,
    super.shelfCurrentVolume,
    super.shelfAvailableCapacity,
    super.qrCodePath,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    final shelfJson = json['shelf'] as Map<String, dynamic>?;
    return StockModel(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'shelfId': shelfId,
    'productId': productId,
    'quantity': quantity,
    'shelfCode': shelfCode,
    'zoneId': zoneId,
    'zoneCode': zoneCode,
    'zoneName': zoneName,
    'aisle': aisle,
    'locationName': locationName,
    'shelfCapacity': shelfCapacity,
    'shelfCurrentVolume': shelfCurrentVolume,
    'shelfAvailableCapacity': shelfAvailableCapacity,
    'qrCodePath': qrCodePath,
  };
}
