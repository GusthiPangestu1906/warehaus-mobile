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
}
