import 'package:zone/domain/entities/shelves.dart';

class ShelfModel extends Shelf {
  ShelfModel({
    required super.id,
    required super.shelfCode,
    required super.aisle,
    required super.capacity,
    required super.currentVolume,
    required super.qrCodePath,
  });

  factory ShelfModel.fromJson(Map<String, dynamic> json) {
    return ShelfModel(
      id: (json['shelfId'] ?? json['id'])?.toString() ?? '',
      shelfCode: (json['shelfCode'] ?? json['binCode']) as String? ?? '',
      aisle: json['aisle'] as int? ?? 0,
      capacity: json['capacity'] as int? ?? 0,
      currentVolume: json['currentVolume'] as int? ?? 0,
      qrCodePath: json['qrCodePath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shelfCode': shelfCode,
      'aisle': aisle,
      'capacity': capacity,
      'currentVolume': currentVolume,
      'qrCodePath': qrCodePath,
    };
  }
}
