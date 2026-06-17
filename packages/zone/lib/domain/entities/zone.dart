import 'package:zone/domain/entities/aisle.dart';
import 'package:zone/domain/entities/shelves.dart';

class Zone {
  final int id;
  final String zoneCode;
  final String zoneName;
  final String category;
  final int categoryId;
  final String description;
  final int totalAisle;
  final int shelfPerAisle;
  final int capacityPerShelf;
  final int emptyShelves;
  final List<Shelf>? shelves;
  final List<Aisle>? aisles;

  Zone({
    required this.id,
    required this.zoneCode,
    required this.zoneName,
    required this.category,
    required this.categoryId,
    required this.description,
    required this.totalAisle,
    required this.shelfPerAisle,
    this.capacityPerShelf = 0,
    this.emptyShelves = 0,
    this.shelves,
    this.aisles,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int? ?? 0,
      zoneCode: json['zoneCode'] as String? ?? '',
      zoneName: json['zoneName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryId: json['categoryId'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      totalAisle: (json['totalAisle'] ?? json['totalAisles']) as int? ?? 0,
      shelfPerAisle:
          (json['shelfPerAisle'] ?? json['totalShelves']) as int? ?? 0,
      capacityPerShelf: json['capacityPerShelf'] as int? ?? 0,
      emptyShelves: json['emptyShelves'] as int? ?? 0,
      shelves: (json['shelves'] is List)
          ? (json['shelves'] as List)
                .map((shelf) => Shelf.fromJson(shelf as Map<String, dynamic>))
                .toList()
          : (json['bins'] is List)
              ? (json['bins'] as List)
                    .map((shelf) => Shelf.fromJson(shelf as Map<String, dynamic>))
                    .toList()
              : null,
      aisles: (json['aisles'] is List)
          ? (json['aisles'] as List)
                .map((aisle) => Aisle.fromJson(aisle as Map<String, dynamic>))
                .toList()
          : (json['aisle'] is List)
              ? (json['aisle'] as List)
                    .map((aisle) => Aisle.fromJson(aisle as Map<String, dynamic>))
                    .toList()
              : null,
    );
  }
}
