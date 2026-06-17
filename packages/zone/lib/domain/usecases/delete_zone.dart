import 'package:zone/domain/repositories/zone_repository.dart';

class DeleteZone {
  final ZoneRepository repository;
  DeleteZone(this.repository);

  Future<void> call(int id) {
    return repository.deleteZone(id);
  }
}
