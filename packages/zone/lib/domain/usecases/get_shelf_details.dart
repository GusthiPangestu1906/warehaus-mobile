import 'package:zone/domain/entities/shelf_detail.dart';
import 'package:zone/domain/repositories/zone_repository.dart';

class GetShelfDetails {
  final ZoneRepository repository;

  GetShelfDetails(this.repository);

  Future<ShelfDetail> call(int shelfId) {
    return repository.getShelfDetails(shelfId);
  }
}