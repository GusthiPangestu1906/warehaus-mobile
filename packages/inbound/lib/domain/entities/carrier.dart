import 'package:equatable/equatable.dart';

class Carrier extends Equatable {
  final int id;
  final String code;
  final String name;
  final String serviceType;

  const Carrier({
    required this.id,
    required this.code,
    required this.name,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [id, code, name, serviceType];
}
