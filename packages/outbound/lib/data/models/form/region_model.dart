import 'package:outbound/domain/entities/form/region.dart';

class RegionModel extends Region {
  const RegionModel({
    required super.id,
    required super.code,
    required super.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  factory RegionModel.fromEntity(Region entity) {
    return RegionModel(id: entity.id, code: entity.code, name: entity.name);
  }
}
