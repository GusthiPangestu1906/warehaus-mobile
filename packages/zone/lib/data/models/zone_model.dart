import 'package:zone/data/models/aisle_model.dart';
import 'package:zone/data/models/shelf_model.dart';
import 'package:zone/domain/entities/aisle.dart';
import 'package:zone/domain/entities/shelves.dart';
import 'package:zone/domain/entities/zone.dart';

class ZoneModel extends Zone {
  ZoneModel({
    required super.id,
    required super.zoneCode,
    required super.zoneName,
    required super.category,
    required super.categoryId,
    required super.description,
    required super.totalAisle,
    required super.shelfPerAisle,
    super.capacityPerShelf,
    super.emptyShelves,
    List<Shelf>? shelves,
    List<Aisle>? aisles,
  }) : super(
         shelves: shelves ?? [],
          aisles: aisles ?? [],
        );

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id']?.toString() ?? '',
      zoneCode: json['zoneCode'] as String? ?? '',
      zoneName: json['zoneName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryId: (json['categoryId'] ?? json['category_id']) as int? ?? 0,
      description: json['description'] as String? ?? '',
      totalAisle: (json['totalAisle'] ?? json['totalAisles']) as int? ?? 0,
      shelfPerAisle:
          (json['shelfPerAisle'] ?? json['totalShelves']) as int? ?? 0,
      capacityPerShelf: json['capacityPerShelf'] as int? ?? 0,
      emptyShelves: json['emptyShelves'] as int? ?? 0,
      shelves: (json['shelves'] ?? json['bins']) != null
          ? ((json['shelves'] ?? json['bins']) as List)
                .map(
                  (shelf) => ShelfModel.fromJson(shelf as Map<String, dynamic>),
                )
                .toList()
          : [],
      aisles: (json['aisle'] ?? json['aisles']) != null
          ? ((json['aisle'] ?? json['aisles']) as List)
                .map(
                  (aisle) => AisleModel.fromJson(aisle as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'zoneCode': zoneCode,
      'zoneName': zoneName,
      'category': category,
      'description': description,
      'totalAisle': totalAisle,
      'shelfPerAisle': shelfPerAisle,
      'capacityPerShelf': capacityPerShelf,
      'emptyShelves': emptyShelves,
    };

    // Only include id if not empty
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    // Only include shelves if not empty
    if (shelves != null && shelves!.isNotEmpty) {
      map['shelves'] = shelves!.map((shelf) {
        if (shelf is ShelfModel) return shelf.toJson();
        return {'id': shelf.id};
      }).toList();
    }

    // Only include aisles if not empty
    if (aisles != null && aisles!.isNotEmpty) {
      map['aisles'] = aisles!.map((aisle) {
        if (aisle is AisleModel) return aisle.toJson();
        return {'aisleNumber': aisle.aisleNumber};
      }).toList();
    }

    return map;
  }
}
