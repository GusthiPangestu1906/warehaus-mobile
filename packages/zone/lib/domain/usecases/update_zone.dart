import 'package:zone/domain/repositories/zone_repository.dart';

class UpdateZone {
  final ZoneRepository repository;
  UpdateZone(this.repository);

  Future<void> call({
    required int id,
    String? zoneName,
    String? category,
    String? description,
  }) {
    return repository.updateZone(
      id: id,
      zoneName: zoneName,
      category: category,
      description: description,
    );
  }
}
