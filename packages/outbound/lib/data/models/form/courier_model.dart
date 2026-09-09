import 'package:outbound/domain/entities/form/courier.dart';

class CourierModel extends Courier {
  const CourierModel({
    required super.code,
    required super.name,
    required super.serviceType,
    required super.isActive,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'serviceType': serviceType,
      'isActive': isActive,
    };
  }

  factory CourierModel.fromEntity(Courier entity) {
    return CourierModel(
      code: entity.code,
      name: entity.name,
      serviceType: entity.serviceType,
      isActive: entity.isActive,
    );
  }
}
