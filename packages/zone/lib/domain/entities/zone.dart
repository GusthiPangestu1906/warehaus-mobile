import 'package:zone/domain/entities/aisle.dart';
import 'package:zone/domain/entities/shelves.dart';

class Zone {
  final int id;
  final String zoneCode;
  final String zoneName;
  final String category;
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
    required this.description,
    required this.totalAisle,
    required this.shelfPerAisle,
    this.capacityPerShelf = 0,
    this.emptyShelves = 0,
    this.shelves,
    this.aisles,
  });
}
