import 'package:zone/domain/repositories/zone_repository.dart';

class UpdateZone {
  final ZoneRepository repository;
  UpdateZone(this.repository);

  Future<void> call({
    required String id,
    String? zoneName,
    int? categoryId,
    String? description,
  }) async {
    return await repository.updateZone(
      id: id,
      zoneName: zoneName,
      categoryId: categoryId,
      description: description,
    );
  }
}
