import 'package:inbound/domain/entities/carrier.dart';

class CarrierModel extends Carrier {
  CarrierModel({
    required super.id,
    required super.code,
    required super.name,
    required super.serviceType,
  });

  factory CarrierModel.fromJson(Map<String, dynamic> json) {
    return CarrierModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      serviceType: json['serviceType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name, 'serviceType': serviceType};
  }

  factory CarrierModel.fromEntity(Carrier entity) {
    return CarrierModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      serviceType: entity.serviceType,
    );
  }
}
